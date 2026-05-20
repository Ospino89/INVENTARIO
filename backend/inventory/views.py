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
from django.db.models import Count
from django.db.models.functions import ExtractHour


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

        movimientos_hoy = Movimiento.objects.filter(creado_en__date=hoy)

        entradas_por_hora = (
            movimientos_hoy.filter(tipo=Movimiento.TipoMovimiento.ENTRADA)
            .annotate(hora=ExtractHour('creado_en'))
            .values('hora')
            .annotate(total=Count('id'))
            .order_by('hora')
        )

        salidas_por_hora = (
            movimientos_hoy.filter(tipo=Movimiento.TipoMovimiento.SALIDA)
            .annotate(hora=ExtractHour('creado_en'))
            .values('hora')
            .annotate(total=Count('id'))
            .order_by('hora')
        )

        entradas_map = {e['hora']: e['total'] for e in entradas_por_hora}
        salidas_map = {s['hora']: s['total'] for s in salidas_por_hora}

        horas = sorted(set(list(entradas_map.keys()) + list(salidas_map.keys())))

        grafica = [
            {
                'hora': h,
                'entradas': entradas_map.get(h, 0),
                'salidas': salidas_map.get(h, 0),
            }
            for h in horas
        ]

        data = {
            'total_productos': Producto.objects.filter(activo=True).count(),
            'productos_bajo_minimo': Producto.objects.filter(
                activo=True,
                stock_actual__lt=models.F('stock_minimo')
            ).count(),
            'total_entradas_hoy': movimientos_hoy.filter(
                tipo=Movimiento.TipoMovimiento.ENTRADA
            ).count(),
            'total_salidas_hoy': movimientos_hoy.filter(
                tipo=Movimiento.TipoMovimiento.SALIDA
            ).count(),
            'grafica': grafica,
        }

        serializer = DashboardSerializer(data)
        return Response(serializer.data)