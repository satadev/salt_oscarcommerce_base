{% set project_name = salt['pillar.get']('project_name') %}
{% set admin_user = salt['pillar.get']('admin_user') %}

{% set postgresql_settings = salt['pillar.get'](project_name + ':postgresql', False) %}
{% set db_name = salt['pillar.get'](project_name + ':postgresql:name', '') %}
{% set db_user = salt['pillar.get'](project_name + ':postgresql:user', '') %}
{% set db_pass = salt['pillar.get'](project_name + ':postgresql:pass', '') %}

{% set source_db_filepath = '/srv/salt/' + project_name + '/source/db/' + db_name + '.sql' %}
{% set is_source_db_exists = salt['file.file_exists'](source_db_filepath) %}


params_db:
    cmd.run:
        - name: 
            echo
            \\n project_name = {{ project_name }}
            \\n admin_user = {{ admin_user }}
            \\n
            \\n postgresql_settings = {% if postgresql_settings != False %}True{% else %}False{% endif %}
            \\n db_name = {{ db_name }}
            \\n db_user = {{ db_user }}
            \\n db_pass = {{ db_pass }}
            \\n
            \\n source_db_filepath = {{ source_db_filepath }}
            \\n is_source_db_exists = {{ is_source_db_exists }}


{% if postgresql_settings %}

# db user create
{{ project_name }}_postgres_user_create:
    postgres_user.present:
        - name: {{ db_user }}
        - password: {{ db_pass }}

# db create
{{ project_name }}_postgres_db_create:
    postgres_database.present:
        - name: {{ db_name }}
        - owner: {{ db_user }}

# db settings
{{ project_name }}_postgres_db_settings:
    file.append:
        - name: /opt/{{ project_name }}/{{ project_name }}/settings_local.py
        - text: |
            DATABASES = {
                'default': {
                    'ENGINE': 'django.db.backends.postgresql_psycopg2',
                    'NAME': '{{ db_name }}',
                    'USER': '{{ db_user }}',
                    'PASSWORD': '{{ db_pass }}',
                    'HOST': '',
                    'port': '',
                }
            }

{% endif %}


{% if is_source_db_exists %}

# db import
{{ project_name }}_db_init:
    cmd.run:
        - cwd: /opt/{{ project_name }}
        - shell: /bin/bash
        - user: {{ admin_user }}
        - name: |
            PGPASSWORD={{ db_pass }} psql -U {{ db_user }} {{ db_name }} < /srv/salt/{{ project_name }}/source/db/{{ project_name }}.sql

{% else %}

# db init
{{ project_name }}_db_init:
    cmd.run:
        - cwd: /opt/{{ project_name }}
        - shell: /bin/bash
        - user: {{ admin_user }}
        - name: |
            export WORKON_HOME=$HOME/.virtualenvs
            source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
            workon {{ project_name }}
            python manage.py migrate
            python manage.py oscar_populate_countries

{{ project_name }}_db_init_complete:
    cmd.run:
        - name:
            echo
            \\n "Run 'python manage.py createsuperuser' to create the Django admin user"
            \\n "Go to http://127.0.0.1:8000/dashboard/ to create at least one 'product class' and one 'fulfillment partner'"

{% endif %}