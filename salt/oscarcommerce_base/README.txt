
Environment
    * Debian 9
    * Salt 2016.11.2
    * Python 2.7.13
    * Django 1.11.4
    * Oscar 1.5
    * PostgreSQL 9.6
    * Nginx 1.10.3
    * Supervisor 3.3.1

    * see `/srv/pillar/oscarcommerce_base.sls` for a list of required packages

Requirements
    * see `/srv/salt/oscarcommerce_base/source/opt/requirements.txt`

Options
    * see `/srv/pillar/oscarcommerce_base_test.sls` for a list of available parameters and options

Description
    This is a Salt application that will bootstrap and teardown a basic Oscar ecommerce project along with a PostgreSQL database, Supervisor, Gunicorn, and Nginx.

    The Salt directives are straight-forward, and the nomenclature is self-explanatory.  Otherwise, questions, comments, or suggestions are always welcome.

    Following is a basic outline of the process.  See the corresponding statefile comments for further descriptions.

Process Outlines
    * bootstrap
        * env
            * update
            * setup (base)
            * setup (project)
        * lib
            * virtualenv
                * update
                * setup
                * create
                * init
        * opt
            * init
            * filestructure
            * settings.py
            * urls.py
            * static files init
            * requirements.txt
        * db
            * db user create
            * db create
            * db settings
            * db init
        * webserver
            * gunicorn
            * supervisor
            * nginx
            * restart services
            * update host file
        * manual steps
            # supervisor restart may fail
                * `sudo service supervisor restart`
            # django admin user creation cannot be automated via salt
                * `python manage.py createsuperuser`

    * teardown
        * services
            * nginx
            * supervisor
            * gunicorn
            * restart services
        * db
            * db
            * db_user
        * lib
            * rmvirtualenv
        * opt
            * rmdir

Commands
    sudo salt kali state.apply oscarcommerce_base.bootstrap \
        pillar="{ \
            project_name: 'oscarcommerce_base_test', \
            admin_user: 'dred', \
        }"
    sudo salt kali state.apply oscarcommerce_base.teardown \
        pillar="{ \
            project_name: 'oscarcommerce_base_test', \
            admin_user: 'dred', \
        }"
        