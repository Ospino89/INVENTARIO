from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Movimiento
from .serializers import MovimientoSerializer


class MovimientoViewSet(viewsets.ModelViewSet):
    queryset = Movimiento.objects.all().select_related('producto', 'autor')
    serializer_class = MovimientoSerializer
    permission_classes = [IsAuthenticated]