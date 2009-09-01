$(function() {
    $('#lessons_tabs').tabs(
    {
        cache: true,
        cookie: { 
            expires: 30,
            name: 'lessons_tabs'
        },
        fx: { 
            opacity: 'toggle',
            duration: 300
        }
    });
    $('#lesson_show_tabs').tabs(
    {
        cache: true,
        cookie: { 
            expires: 30,
            name: 'lesson_show_tabs'
        },
        fx: { 
            opacity: 'toggle',
            duration: 300
        }
    });
    $('#account_settings_tabs').tabs(
    {
        cookie: { 
            expires: 30,
            name: 'account_settings_tabs'
        },
        fx: { 
            opacity: 'toggle',
            duration: 300
        },
    });
    $('#admin_user_tabs').tabs(
    {
        cookie: { 
            expires: 30,
            name: 'admin_user_tabs'
        },
        fx: { 
            opacity: 'toggle',
            duration: 300
        },
    });
});
