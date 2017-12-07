{% set base_app = 'oscarcommerce_base' %}
{% set project_name = salt['pillar.get']('project_name') %}
{% set admin_user = salt['pillar.get']('admin_user') %}

{% set source_opt_dirpath = '/srv/salt/' + project_name + '/source/opt/' + project_name %}
{% set is_source_opt_exists = salt['file.directory_exists'](source_opt_dirpath) %}

params_opt:
    cmd.run:
        - name:
            echo
            \\n base_app = {{ base_app }}
            \\n project_name = {{ project_name }}
            \\n admin_user = {{ admin_user }}
            \\n
            \\n source_opt_dirpath = {{ source_opt_dirpath }}
            \\n is_source_opt_exists = {{ is_source_opt_exists }}


{% if is_source_opt_exists %}

# restore from backup
{{ project_name }}_opt_setup:
    file.recurse:
        - source: salt://{{ project_name }}/source/opt/{{ project_name }}
        - name: /opt/{{ project_name }}
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - unless: ls /opt/{{ project_name }}

{% else %}

# setup from scratch using template files in base_app

# init
{{ project_name }}_opt_init:
    cmd.run:
        - cwd: /opt/
        - shell: /bin/bash
        - user: {{ admin_user }}
        - name: |
            export WORKON_HOME=$HOME/.virtualenvs
            source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
            workon {{ project_name }}
            django-admin startproject {{ project_name }}
        - unless: ls /opt/{{ project_name }}/manage.py


#
# filestructure
#
# log/ dir
{{ project_name }}_opt_log:
    file.recurse:
        - source: salt://{{ base_app }}/source/opt/log
        - name: /opt/{{ project_name }}/log/
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - unless: ls /opt/{{ project_name }}/log

# media/ dir
{{ project_name }}_opt_media:
    file.recurse:
        - source: salt://{{ base_app }}/source/opt/media
        - name: /opt/{{ project_name }}/media/
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - unless: ls /opt/{{ project_name }}/media

# static/ dir
{{ project_name }}_opt_static:
    file.directory:
        - name: /opt/{{ project_name }}/static
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - mode: 755
        - unless: ls /opt/{{ project_name }}/static


#
# settings.py
#
# main
{{ project_name }}_opt_settings:
    file.managed:
        - source: salt://{{ base_app }}/source/opt/settings.py
        - name: /opt/{{ project_name }}/{{ project_name }}/settings.py
        - template: jinja
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - unless: ls /opt/{{ project_name }}/{{ project_name }}/settings_local.py

# local
{{ project_name }}_opt_settings_local:
    file.managed:
        - source: salt://{{ base_app }}/source/opt/settings_local.py
        - name: /opt/{{ project_name }}/{{ project_name }}/settings_local.py
        - template: jinja
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - unless: ls /opt/{{ project_name }}/{{ project_name }}/settings_local.py


#
# urls.py
#
# main
{{ project_name }}_opt_urls:
    file.managed:
        - source: salt://{{ base_app }}/source/opt/urls.py
        - name: /opt/{{ project_name }}/{{ project_name }}/urls.py
        - template: jinja
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - unless: ls /opt/{{ project_name }}/{{ project_name }}/urls_local.py

# local
{{ project_name }}_opt_urls_local:
    file.managed:
        - source: salt://{{ base_app }}/source/opt/urls_local.py
        - name: /opt/{{ project_name }}/{{ project_name }}/urls_local.py
        - template: jinja
        - user: {{ admin_user }}
        - group: {{ admin_user }}
        - unless: ls /opt/{{ project_name }}/{{ project_name }}/urls_local.py


#
# static/ files init
#
# collectstatic
{{ project_name }}_opt_static_collectstatic:
    cmd.run:
        - cwd: /opt/{{ project_name }}
        - shell: /bin/bash
        - user: {{ admin_user }}
        - name: |
            export WORKON_HOME=$HOME/.virtualenvs
            source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
            workon {{ project_name }}
            python manage.py collectstatic --no-input
        - unless: ls /opt/{{ project_name }}/static/admin

# mv files
{{ project_name }}_opt_static_mv:
    cmd.run:
        - shell: /bin/bash
        - user: {{ admin_user }}
        - name: rsync -av /opt/{{ project_name }}/static_root/ /opt/{{ project_name }}/static
        - unless: ls /opt/{{ project_name }}/static/admin

{% endif %}


#
# update requirements.txt
#
{{ project_name }}_opt_requirements:
    cmd.run:
        - cwd: /opt/{{ project_name }}
        - shell: /bin/bash
        - user: {{ admin_user }}
        - name: |
            export WORKON_HOME=$HOME/.virtualenvs
            source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
            workon {{ project_name }}
            pip freeze > requirements.txt
        - unless: ls /opt/{{ project_name }}/requirements.txt
