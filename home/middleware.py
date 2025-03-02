from django.utils.deprecation import MiddlewareMixin

from home.models import VisitorMetadata


class TrackVisit(MiddlewareMixin):
    def process_request(self, request):
        visit = VisitorMetadata(ip_addr=request.META.get('REMOTE_ADDR', None),
                                referer=request.META.get('HTTP_REFERER', None),
                                path=request.get_full_path())
        visit.save()