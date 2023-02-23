# Generated by Django 3.2.6 on 2021-08-25 16:55

from django.db import migrations, models
import django.db.models.deletion
import django_lifecycle.mixins
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0073_encrypt_remote_fields'),
    ]

    operations = [
        migrations.CreateModel(
            name='AlternateContentSource',
            fields=[
                ('pulp_id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('pulp_created', models.DateTimeField(auto_now_add=True)),
                ('pulp_last_updated', models.DateTimeField(auto_now=True, null=True)),
                ('pulp_type', models.TextField(db_index=True, default=None)),
                ('name', models.TextField(db_index=True, unique=True)),
                ('last_refreshed', models.DateTimeField(null=True)),
                ('remote', models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, to='core.remote')),
            ],
            options={
                'verbose_name_plural': 'acs',
            },
            bases=(django_lifecycle.mixins.LifecycleModelMixin, models.Model),
        ),
        migrations.CreateModel(
            name='AlternateContentSourcePath',
            fields=[
                ('pulp_id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('pulp_created', models.DateTimeField(auto_now_add=True)),
                ('pulp_last_updated', models.DateTimeField(auto_now=True, null=True)),
                ('path', models.TextField(default=None)),
                ('alternate_content_source', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='paths', to='core.alternatecontentsource')),
                ('repository', models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to='core.repository')),
            ],
            options={
                'unique_together': {('alternate_content_source', 'path')},
            },
            bases=(django_lifecycle.mixins.LifecycleModelMixin, models.Model),
        ),
    ]