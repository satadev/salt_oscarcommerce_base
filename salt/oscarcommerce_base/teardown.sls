{% set project_name = salt['pillar.get']('project_name') %}
{% set admin_user = salt['pillar.get']('users:admin_user') %}

{% set db_name = salt['pillar.get'](project_name + ':postgresql:name', False) %}
{% set db_user = salt['pillar.get'](project_name + ':postgresql:user', False) %}


params:
    cmd.run:
        - name: 
            echo
            \\n project_name = {{ project_name }}
            \\n admin_user = {{ admin_user }}
            \\n
            \\n db_name = {{ db_name }}
            \\n db_user = {{ db_user }}


#
# services
#
# nginx
{{ project_name }}_nginx_settings_delete:
    file.absent:
        - name: /etc/nginx/sites-available/{{ project_name }}

{{ project_name }}_nginx_deactivate:
    file.absent:
        - name: /etc/nginx/sites-enabled/{{ project_name }}

# supervisor
{{ project_name }}_supervisor_settings_delete:
    file.absent:
        - name: /etc/supervisor/conf.d/{{ project_name }}.conf

# gunicorn
{{ project_name }}_gunicorn_settings_delete:
    file.absent:
        - name: /opt/{{ project_name }}/gunicorn.sh

# reload services
{{ project_name }}_services_reload:
    cmd.run:
        - name: |
            service nginx stop
            service nginx start
            service supervisor stop
            service supervisor start
        - stateful: True

# hosts file
{{ project_name }}_hosts_delete:
    file.line:
        - name: /etc/hosts
        - mode: delete
        - content: 127.0.0.1 {% for item in salt['pillar.get'](project_name + ':nginx:server_name') %}{{ item }} {% endfor %}


#
# postgres
#

{% if db_name %}
# db
{{ project_name }}_postgres_db_delete:
    postgres_database.absent:
        - name: {{ db_name }}
{% endif %}

{% if db_user %}
# user
{{ project_name }}_postgres_user_delete:
    postgres_user.absent:
        - name: {{ db_user }}
{% endif %}


#
# lib
#
{{ project_name }}_virtualenv_delete:
    cmd.run:
        - user: {{ admin_user }}
        - shell: /bin/bash
        - name: |
            export WORKON_HOME=$HOME/.virtualenvs
            source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
            rmvirtualenv {{ project_name }}


#
# opt
#
{{ project_name }}_opt_delete:
    file.absent:
        - name: /opt/{{ project_name }}
