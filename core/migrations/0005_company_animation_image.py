# Generated by Django 4.2.16 on 2024-10-22 13:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0004_company_animation_video_company_background'),
    ]

    operations = [
        migrations.AddField(
            model_name='company',
            name='animation_image',
            field=models.ImageField(db_column='animation_image', default='', upload_to=''),
            preserve_default=False,
        ),
    ]
