{% set project_name = salt['pillar.get']('project_name') %}{% set admin_user = salt['pillar.get']('users:admin_user') %}{% set num_workers = salt['pillar.get'](project_name + ':gunicorn:num_workers') %}#!/bin/bash

NAME='{{ project_name }}'

BASE_DIR=/opt/{{ project_name }}
VIRTUALENV_DIR=~/.virtualenvs/{{ project_name }}
SOCKET_PATH=/opt/{{ project_name }}/gunicorn.sock

NUM_WORKERS={{ num_workers }}
MAX_REQUESTS={{ num_workers }}

DJANGO_WSGI_MODULE={{ project_name }}.wsgi
DJANGO_SETTINGS_MODULE={{ project_name }}.settings

USER={{ admin_user }}
GROUP={{ admin_user }}

export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$BASE_DIR:$PYTHONPATH

echo "Starting $NAME as `whoami`"

cd $VIRTUALENV_DIR
source bin/activate

cd $BASE_DIR
exec gunicorn \
--name $NAME \
--workers $NUM_WORKERS \
--max-requests $MAX_REQUESTS \
--user=$USER --group=$GROUP \
--bind unix:$SOCKET_PATH ${DJANGO_WSGI_MODULE}:application \
--log-level=error \
--log-file=-
