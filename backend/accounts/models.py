from django.db import models
from django.contrib.auth.models import AbstractUser
import uuid


class CustomUser(AbstractUser):
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )

    class Role(models.TextChoices):
        ADMIN = 'ADMIN', 'Administrador'
        OPERARIO = 'OPERARIO', 'Operario'

    role = models.CharField(
        max_length=10,
        choices=Role.choices,
        default=Role.OPERARIO,
    )

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"