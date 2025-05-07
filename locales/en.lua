local Translations = {
    error = {
        not_authorized = 'You are not authorized to use this command',
        no_business = 'No business found with that ID',
        invalid_data = 'Invalid data',
        db_error = 'Database error',
        invalid_coordinates = 'Invalid coordinates',
    },
    success = {
        business_saved = 'Business saved successfully',
        business_deleted = 'Business deleted successfully',
        npc_added = 'NPC added successfully',
        npc_deleted = 'NPC deleted successfully',
        marker_added = 'Marker added successfully',
        marker_deleted = 'Marker deleted successfully',
        item_added = 'Item added successfully',
        item_deleted = 'Item deleted successfully',
    },
    info = {
        command_usage = 'Usage: /businesspanel [id]',
        business_list = 'Business list:',
        panel_opened = 'Business panel opened',
        panel_closed = 'Business panel closed',
    },
    menu = {
        title = 'Business Panel',
        edit_business = 'Edit Business',
        save_business = 'Save Business',
        delete_business = 'Delete Business',
        general_info = 'General Information',
        employees = 'Employees',
        markers = 'Markers',
        npcs = 'NPCs',
        items = 'Items',
        stats = 'Statistics',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})