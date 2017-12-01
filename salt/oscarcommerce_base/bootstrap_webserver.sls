{% set base_app = 'oscarcommerce_base' %}
{% set project_name = salt['pillar.get']('project_name') %}
{% set admin_user = salt['pillar.get']('admin_user') %}

{% set source_gunicorn_filepath = '/srv/salt/' + project_name + '/source/opt/' + project_name + '/gunicorn.sh' %}
{% set source_supervisor_filepath = '/srv/salt/' + project_name + '/source/etc/supervisor/conf.d/' + project_name + '.conf' %}
{% set source_nginx_filepath = '/srv/salt/' + project_name + '/source/etc/nginx/sites-available/' + project_name %}
{% set is_source_gunicorn_exists = salt['file.file_exists'](source_gunicorn_filepath) %}
{% set is_source_supervisor_exists = salt['file.file_exists'](source_supervisor_filepath) %}
{% set is_source_nginx_exists = salt['file.file_exists'](source_nginx_filepath) %}


params_webserver:
    cmd.run:
        - name: 
            echo
            \\n base_app = {{ base_app }}
            \\n project_name = {{ project_name }}
            \\n admin_user = {{ admin_user }}
            \\n
            \\n source_gunicorn_filepath = {{ source_gunicorn_filepath }}
            \\n source_supervisor_filepath = {{ source_supervisor_filepath }}
            \\n source_nginx_filepath = {{ source_nginx_filepath }}
            \\n is_source_gunicorn_exists = {{ is_source_gunicorn_exists }}
            \\n is_source_supervisor_exists = {{ is_source_supervisor_exists }}
            \\n is_source_nginx_exists = {{ is_source_nginx_exists }}


#
# gunicorn
#
{{ project_name }}_gunicorn_settings:
    file.managed:
        - source: {% if is_source_gunicorn_exists %}salt://{{ project_name }}/source/opt/{{ project_name }}/gunicorn.sh{% else %}salt://{{ base_app }}/source/opt/gunicorn.sh{% endif %}
        - template: jinja
        - name: /opt/{{ project_name }}/gunicorn.sh
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - mode: 744

#
# supervisor
#
{{ project_name }}_supervisor_reload:
    service.running:
        - name: supervisor
        - enable: True
        - watch:
            - file: /etc/supervisor/conf.d/{{ project_name }}.conf

{{ project_name }}_supervisor_settings:
    file.managed:
        - source: {% if is_source_supervisor_exists %}salt://{{ project_name }}/source/etc/supervisor/conf.d/{{ project_name }}.conf{% else %}salt://{{ base_app }}/source/etc/supervisor.conf{% endif %}
        - template: jinja
        - name: /etc/supervisor/conf.d/{{ project_name }}.conf
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - mode: 644

#
# nginx
#
{{ project_name }}_nginx_reload:
    service.running:
        - name: nginx
        - enable: True
        - watch:
            - file: /etc/nginx/sites-enabled/{{ project_name }}

{{ project_name }}_nginx_settings:
    file.managed:
        - source: {% if is_source_nginx_exists %}salt://{{ project_name }}/source/etc/nginx/sites-available/{{ project_name }}{% else %}salt://{{ base_app }}/source/etc/nginx{% endif %}
        - template: jinja
        - name: /etc/nginx/sites-available/{{ project_name }}
        - mode: 644

{{ project_name }}_nginx_activate:
    file.symlink:
        - name: /etc/nginx/sites-enabled/{{ project_name }}
        - target: /etc/nginx/sites-available/{{ project_name }}

{% if grains['id'] == 'kali' %}
#
# hosts file
#
{{ project_name }}_hosts_init:
    file.append:
        - name: /etc/hosts
        - text: |
            127.0.0.1 {% for item in salt['pillar.get'](project_name + ':nginx:server_name') %}{{ item }} {% endfor %}
{% endif %}

#
# restart services / activate
#
{{ project_name }}_services_reload:
    cmd.run:
        - name: |
            service nginx stop
            service nginx start
            service supervisor stop
            service supervisor start
        - stateful: True
