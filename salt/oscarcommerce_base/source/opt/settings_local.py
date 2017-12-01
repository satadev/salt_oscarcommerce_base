from settings import *


#
# debug
#
DEBUG = True
INTERNAL_IPS = ['127.0.0.1',]

if DEBUG:
    INSTALLED_APPS += [
        'debug_toolbar',
        'django.contrib.admin',
    ]

    MIDDLEWARE = [
        'debug_toolbar.middleware.DebugToolbarMiddleware',
    ] + MIDDLEWARE

    # activate debug_toolbar for gunicorn & nginx
    DEBUG_TOOLBAR_CONFIG = {
        'SHOW_TOOLBAR_CALLBACK': lambda request: True
    }


