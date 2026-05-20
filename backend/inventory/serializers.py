from rest_framework import serializers
from .models import Categoria, Producto


class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categoria
        fields = ['id', 'nombre', 'descripcion', 'activo']


class ProductoSerializer(serializers.ModelSerializer):
    categoria_nombre = serializers.CharField(
        source='categoria.nombre',
        read_only=True
    )

    class Meta:
        model = Producto
        fields = [
            'id', 'sku', 'nombre', 'descripcion',
            'stock_actual', 'stock_minimo',
            'categoria', 'categoria_nombre',
            'imagen', 'activo', 'creado_en', 'actualizado_en'
        ]
        read_only_fields = ['id', 'creado_en', 'actualizado_en']


class GraficaHoraSerializer(serializers.Serializer):
    hora = serializers.IntegerField()
    entradas = serializers.IntegerField()
    salidas = serializers.IntegerField()



class DashboardSerializer(serializers.Serializer):
    total_productos = serializers.IntegerField(read_only=True)
    productos_bajo_minimo = serializers.IntegerField(read_only=True)
    total_entradas_hoy = serializers.IntegerField(read_only=True)
    total_salidas_hoy = serializers.IntegerField(read_only=True)
    grafica = GraficaHoraSerializer(many=True, read_only=True)



    