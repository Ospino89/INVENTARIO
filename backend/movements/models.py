from django.db import models
from django.conf import settings
from inventory.models import Producto


class Movimiento(models.Model):
    class TipoMovimiento(models.TextChoices):
        ENTRADA = 'ENTRADA', 'Entrada'
        SALIDA = 'SALIDA', 'Salida'

    producto = models.ForeignKey(
        Producto,
        on_delete=models.PROTECT,
        related_name='movimientos'
    )
    tipo = models.CharField(
        max_length=10,
        choices=TipoMovimiento.choices,
    )
    cantidad = models.PositiveIntegerField()
    autor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='movimientos'
    )
    notas = models.TextField(blank=True, null=True)
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Movimiento'
        verbose_name_plural = 'Movimientos'
        ordering = ['-creado_en']



    def save(self, *args, **kwargs):
        if self.tipo == self.TipoMovimiento.ENTRADA:
            self.producto.stock_actual += self.cantidad
        elif self.tipo == self.TipoMovimiento.SALIDA:
            self.producto.stock_actual -= self.cantidad
        self.producto.save()
        super().save(*args, **kwargs)
    

    def __str__(self):
        return f"{self.tipo} - {self.producto.nombre} ({self.cantidad})"