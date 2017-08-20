from urls import *
from django.conf import settings
from django.contrib import admin


#
# media files
#
if settings.DEBUG:
    from django.conf.urls.static import static
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


#
# debug toolbar
#
if settings.DEBUG:
    import debug_toolbar
    urlpatterns = [
        url(r'^admin/', admin.site.urls),
        url(r'^__debug__/', include(debug_toolbar.urls)),
    ] + urlpatterns
