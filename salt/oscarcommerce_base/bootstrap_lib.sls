{% set base_app = 'oscarcommerce_base' %}
{% set admin_user = salt['pillar.get']('admin_user') %}
{% set project_name = salt['pillar.get']('project_name') %}

{% set source_opt_dirpath = '/srv/salt/' + project_name + '/source/opt/' + project_name %}
{% set is_source_opt_exists = salt['file.directory_exists'](source_opt_dirpath) %}


params_lib:
    cmd.run:
        - name: 
            echo
            \\n base_app = {{ base_app }}
            \\n project_name = {{ project_name }}
            \\n admin_user = {{ admin_user }}
            \\n
            \\n source_opt_dirpath = {{ source_opt_dirpath }}
            \\n is_source_opt_exists = {{ is_source_opt_exists }}


#
# lib
#
#   * update (pip)
#   * setup
#       * install virtualenv
#   * create
#       * create project virtualenv (if not exists)
#   * init
#       * install requirements
#           - the values are set according
#               to the following progression with the first existing
#               value taking precedence:
#                   -> project-specific
#                   -> base_app

# update
{{ project_name }}_pip_upgrade:
    cmd.run:
        - name: python -m pip install -U pip

# setup
{{ project_name }}_virtualenv_setup:
    pip.installed:
        - name: virtualenvwrapper

# create
{{ project_name }}_virtualenv_create:
    cmd.run:
        - user: {{ admin_user }}
        - shell: /bin/bash
        - name: |
            export WORKON_HOME=$HOME/.virtualenvs
            source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
            mkvirtualenv {{ project_name }} --no-site-packages
        - check_cmd: 
            - /bin/true
        - unless: ls /home/{{ admin_user }}/.virtualenvs/{{ project_name }}

# init
{{ project_name }}_virtualenv_init:
    pip.installed:
        - user: {{ admin_user }}
        - bin_env: /home/{{ admin_user }}/.virtualenvs/{{ project_name }}
        - requirements: {% if is_source_opt_exists %}salt://{{ project_name }}/source/opt/{{ project_name }}/requirements.txt{% else %}salt://{{ base_app }}/source/opt/requirements.txt{% endif %}
        - process_dependency_links: True
        - upgrade: True
        - env_vars:
            VERBOSE: 'True'
