local Translations = {
    error = {
        not_authorized = 'No estás autorizado para usar este comando',
        no_business = 'No se ha encontrado ningún negocio con ese ID',
        invalid_data = 'Datos inválidos',
        db_error = 'Error en la base de datos',
        invalid_coordinates = 'Coordenadas inválidas',
    },
    success = {
        business_saved = 'Negocio guardado correctamente',
        business_deleted = 'Negocio eliminado correctamente',
        npc_added = 'NPC añadido correctamente',
        npc_deleted = 'NPC eliminado correctamente',
        marker_added = 'Marcador añadido correctamente',
        marker_deleted = 'Marcador eliminado correctamente',
        item_added = 'Ítem añadido correctamente',
        item_deleted = 'Ítem eliminado correctamente',
    },
    info = {
        command_usage = 'Uso: /businesspanel [id]',
        business_list = 'Lista de negocios:',
        panel_opened = 'Panel de negocios abierto',
        panel_closed = 'Panel de negocios cerrado',
    },
    menu = {
        title = 'Panel de Negocios',
        edit_business = 'Editar Negocio',
        save_business = 'Guardar Negocio',
        delete_business = 'Eliminar Negocio',
        general_info = 'Información General',
        employees = 'Empleados',
        markers = 'Marcadores',
        npcs = 'NPCs',
        items = 'Ítems',
        stats = 'Estadísticas',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})