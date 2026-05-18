from rest_framework import serializers
from .models import Movimiento
from django.contrib.auth import get_user_model

User = get_user_model()


class MovimientoSerializer(serializers.ModelSerializer):
    autor_username = serializers.CharField(
        source='autor.username',
        read_only=True
    )
    producto_nombre = serializers.CharField(
        source='producto.nombre',
        read_only=True
    )
    autor = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.all()
    )

    class Meta:
        model = Movimiento
        fields = [
            'id', 'producto', 'producto_nombre',
            'tipo', 'cantidad',
            'autor', 'autor_username',
            'notas', 'creado_en'
        ]
        read_only_fields = ['id', 'creado_en']

    def validate(self, data):
        if data['tipo'] == Movimiento.TipoMovimiento.SALIDA:
            stock_actual = data['producto'].stock_actual
            if data['cantidad'] > stock_actual:
                raise serializers.ValidationError(
                    f"Stock insuficiente. Stock actual: {stock_actual}, "
                    f"cantidad solicitada: {data['cantidad']}."
                )
        return data