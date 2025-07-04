function sendData(name, data, cb) {
    $.post(`https://${GetParentResourceName()}/${name}`, JSON.stringify(data), cb);
}

Chart.defaults.color = '#fff';
Chart.defaults.borderColor = 'rgba(255, 255, 255, 0.1)';

const chartColors = [
    'rgba(76, 175, 80, 0.7)',
    'rgba(76, 107, 175, 0.7)',
    'rgba(255, 152, 0, 0.7)',
    'rgba(156, 39, 176, 0.7)',
    'rgba(233, 30, 99, 0.7)'
];

const app = new Vue({
    el: '#app',
    data: {
        currentView: 'hidden',
        searchTerm: '',
        businesses: [],
        selectedBusiness: null,
        currentTab: 'general',
        businessTypes: ['shop', 'mechanic', 'police', 'ambulance', 'custom'],
        newBusiness: {
            id: '',
            label: '',
            type: 'shop'
        },
        showConfirmModal: false,
        confirmMessage: '',
        confirmCallback: null,
        moneyChart: null,
        dutyLogs: []
    },
    computed: {
        filteredBusinesses() {
            if (!this.searchTerm) return this.businesses;
            const search = this.searchTerm.toLowerCase();
            return this.businesses.filter(business => 
                business.label.toLowerCase().includes(search) || 
                business.id.toLowerCase().includes(search)
            );
        }
    },
    methods: {
        closePanel() {
            this.currentView = 'hidden';
            sendData('closePanel', {});
        },
        formatDate(timestamp) {
            const date = new Date(parseInt(timestamp));
            return date.toLocaleString();
        },
        
        showBusinessList(businesses) {
            this.businesses = businesses;
            this.currentView = 'list';
        },
        selectBusiness(businessId) {
            //console.log("Seleccionando negocio:", businessId);
            sendData('getBusinessData', { businessId }, (response) => {
                //console.log("Respuesta recibida:", response);
                if (response && response.success && response.data) {
                    this.showBusinessEditor(response.data);
                } else {
                    //console.error("Error al obtener datos del negocio:", response);
                }
            });
        },
        showNewBusinessForm() {
            this.newBusiness = {
                id: '',
                label: '',
                type: 'shop'
            };
            this.currentView = 'new';
        },
        
        createBusiness() {
            if (!this.newBusiness.id || !this.newBusiness.label) {
                return;
            }
            
            sendData('createBusiness', this.newBusiness);
            this.currentView = 'list';
        },
        
        showBusinessEditor(businessData) {
            //console.log("Mostrando editor para:", businessData);
            
            if (typeof businessData.grades === 'string') {
                try {
                    businessData.grades = JSON.parse(businessData.grades);
                } catch(e) {
                    //console.error("Error al parsear grades:", e);
                    businessData.grades = {};
                }
            } else if (!businessData.grades) {
                businessData.grades = {};
            }
            
            if (typeof businessData.npcs === 'string') {
                try {
                    businessData.npcs = JSON.parse(businessData.npcs);
                } catch(e) {
                    //console.error("Error al parsear npcs:", e);
                    businessData.npcs = [];
                }
            } else if (!businessData.npcs) {
                businessData.npcs = [];
            }
            
            if (typeof businessData.stats === 'string') {
                try {
                    businessData.stats = JSON.parse(businessData.stats);
                } catch(e) {
                    //console.error("Error al parsear stats:", e);
                    businessData.stats = { duty: [], money: [] };
                }
            } else if (!businessData.stats) {
                businessData.stats = { duty: [], money: [] };
            }
            
            this.selectedBusiness = businessData;
            this.currentView = 'editor';
            this.currentTab = 'general';
            
            this.dutyLogs = (businessData.stats && businessData.stats.duty) ? businessData.stats.duty : [];
            this.initCharts();
        },
        closeBusiness() {
            this.selectedBusiness = null;
            this.currentView = 'list';
        },
        
        saveGeneral() {
            if (!this.selectedBusiness) return;
            
            /*console.log("Guardando datos generales:", {
                businessId: this.selectedBusiness.id,
                generalData: {
                    label: this.selectedBusiness.label,
                    type: this.selectedBusiness.type,
                    level: this.selectedBusiness.level,
                    experience: this.selectedBusiness.experience,
                    money: this.selectedBusiness.money,
                    open: this.selectedBusiness.open
                }
            }); */
            
            sendData('updateBusinessGeneral', {
                businessId: this.selectedBusiness.id,
                generalData: {
                    label: this.selectedBusiness.label,
                    type: this.selectedBusiness.type,
                    level: this.selectedBusiness.level,
                    experience: this.selectedBusiness.experience,
                    money: this.selectedBusiness.money,
                    open: this.selectedBusiness.open
                }
            });
        },
        
        addGrade() {
            if (!this.selectedBusiness) return;
            
            const keys = Object.keys(this.selectedBusiness.grades);
            const newKey = keys.length > 0 ? (parseInt(keys[keys.length - 1]) + 1).toString() : "0";
            
            Vue.set(this.selectedBusiness.grades, newKey, {
                label: "Nuevo Rango",
                pay: 1000,
                boss: false
            });
        },
        deleteGrade(key) {
            if (!this.selectedBusiness) return;
            
            this.confirmMessage = `¿Estás seguro de que quieres eliminar el rango ${this.selectedBusiness.grades[key].label}?`;
            this.confirmCallback = () => {
                Vue.delete(this.selectedBusiness.grades, key);
                this.showConfirmModal = false;
            };
            this.showConfirmModal = true;
        },
        saveGrades() {
            if (!this.selectedBusiness) return;
            
            sendData('updateBusinessGrades', {
                businessId: this.selectedBusiness.id,
                grades: this.selectedBusiness.grades
            });
        },
        
        addNPC() {
            if (!this.selectedBusiness) return;
            
            const newNPC = {
                name: "Nuevo NPC",
                model: "a_m_m_business_01",
                coords: { x: 0, y: 0, z: 0, w: 0 },
                main: false,
                code: Date.now().toString()
            };
            
            this.selectedBusiness.npcs.push(newNPC);
        },
        deleteNPC(index) {
            if (!this.selectedBusiness) return;
            
            this.confirmMessage = `¿Estás seguro de que quieres eliminar el NPC ${this.selectedBusiness.npcs[index].name}?`;
            this.confirmCallback = () => {
                this.selectedBusiness.npcs.splice(index, 1);
                this.showConfirmModal = false;
            };
            this.showConfirmModal = true;
        },
        setNPCPosition(index) {
            if (!this.selectedBusiness) return;
            
            sendData('getCurrentPosition', {}, (coords) => {
                Vue.set(this.selectedBusiness.npcs[index], 'coords', coords);
            });
        },
        saveNPCs() {
            if (!this.selectedBusiness) return;
            
            sendData('updateBusinessNPCs', {
                businessId: this.selectedBusiness.id,
                npcs: this.selectedBusiness.npcs
            });
        },
        
        initCharts() {
            setTimeout(() => {
                this.initMoneyChart();
            }, 100);
        },
        initMoneyChart() {
            const ctx = document.getElementById('moneyChart');
            if (!ctx) return;
            
            if (this.moneyChart) {
                this.moneyChart.destroy();
            }
            
            let labels = [];
            let data = [];
            
            if (this.selectedBusiness && this.selectedBusiness.stats && this.selectedBusiness.stats.money) {
                labels = this.selectedBusiness.stats.money.map(item => item.date);
                data = this.selectedBusiness.stats.money.map(item => item.money);
            }
            
            this.moneyChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Dinero',
                        data: data,
                        backgroundColor: 'rgba(76, 175, 80, 0.2)',
                        borderColor: 'rgba(76, 175, 80, 1)',
                        borderWidth: 2,
                        tension: 0.3,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(255, 255, 255, 0.1)'
                            }
                        },
                        x: {
                            grid: {
                                color: 'rgba(255, 255, 255, 0.1)'
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });
        },
        
        confirmDelete() {
            if (!this.selectedBusiness) return;
            
            this.confirmMessage = `¿Estás seguro de que quieres eliminar el negocio ${this.selectedBusiness.label}? Esta acción no se puede deshacer.`;
            this.confirmCallback = () => {
                sendData('deleteBusiness', { businessId: this.selectedBusiness.id });
                this.closeBusiness();
                this.showConfirmModal = false;
            };
            this.showConfirmModal = true;
        },
        
        confirmAction() {
            if (this.confirmCallback) {
                this.confirmCallback();
            }
        }
    },
    mounted() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            if (!data.action) return;
            
            console.log("Mensaje recibido:", data.action, data);
            
            switch (data.action) {
                case 'openBusinessList':
                    this.showBusinessList(data.businesses);
                    break;
                    
                case 'openBusinessPanel':
                    this.showBusinessEditor(data.data);
                    break;
                    
                case 'closeBusinessPanel':
                    this.closePanel();
                    break;
            }
        });
        
        setTimeout(() => {
            sendData('nui:ready', {});
        }, 500);
        
        document.addEventListener('keyup', (event) => {
            if (event.key === 'Escape') {
                if (this.showConfirmModal) {
                    this.showConfirmModal = false;
                } else if (this.currentView === 'editor') {
                    this.closeBusiness();
                } else if (this.currentView === 'new') {
                    this.currentView = 'list';
                } else if (this.currentView === 'list') {
                    this.closePanel();
                }
            }
        });
    }
});

function GetParentResourceName() {
    try {
        return window.GetParentResourceName();
    } catch (e) {
        return 'df_businesspanel';
    }
}