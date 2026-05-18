from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from accounts.permissions import IsAdministrador
from .models import Categoria, Producto
from .serializers import CategoriaSerializer, ProductoSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from django.utils import timezone
from movements.models import Movimiento
from .serializers import DashboardSerializer
from django.db import models


class CategoriaViewSet(viewsets.ModelViewSet):
    queryset = Categoria.objects.filter(activo=True)
    serializer_class = CategoriaSerializer
    permission_classes = [IsAuthenticated]


class ProductoViewSet(viewsets.ModelViewSet):
    queryset = Producto.objects.filter(activo=True).select_related('categoria')
    serializer_class = ProductoSerializer

    def get_permissions(self):
        if self.action in ['create', 'destroy', 'update', 'partial_update']:
            return [IsAdministrador()]
        return [IsAuthenticated()]

class DashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        hoy = timezone.now().date()

        data = {
            'total_productos': Producto.objects.filter(activo=True).count(),
            'productos_bajo_minimo': Producto.objects.filter(
                activo=True,
                stock_actual__lt=models.F('stock_minimo')
            ).count(),
            'total_entradas_hoy': Movimiento.objects.filter(
                tipo=Movimiento.TipoMovimiento.ENTRADA,
                creado_en__date=hoy
            ).count(),
            'total_salidas_hoy': Movimiento.objects.filter(
                tipo=Movimiento.TipoMovimiento.SALIDA,
                creado_en__date=hoy
            ).count(),
        }

        serializer = DashboardSerializer(data)
        return Response(serializer.data)    