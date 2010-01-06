$(function() {

    $('#account_settings_tabs').tabs(
    {
        cookie: {
            expires: 30,
            name: 'account_settings_tabs'
        },
        fx: {
            opacity: 'toggle',
            duration: 300
        }
    });

    $('#admin-user-tabs').tabs(
    {
        cookie: {
            expires: 30,
            name: 'admin-user-tabs'
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

    $('#my_stuff_tabs').tabs(
    {
        cache: true,
        cookie: {
            expires: 30,
            name: 'my_stuff_tabs'
        },
        fx: {
            opacity: 'toggle',
            duration: 300
        }
    });

    $('#my_stuff_tabs_nested').tabs(
    {
        cache: true,
        fx: {
            opacity: 'toggle',
            duration: 300
        }
    });

    $('#policy_tabs').tabs(
    {
        cache: true,
        cookie: {
            expires: 30,
            name: 'policy_tabs'
        },
        fx: {
            opacity: 'toggle',
            duration: 300
        }
    });

    $('#user_show_tabs').tabs(
    {
        fx: {
            opacity: 'toggle',
            duration: 300
        }
    });

});
