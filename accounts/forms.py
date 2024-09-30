from django import forms
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from .models import CustomUser

class CustomUserCreationForm(UserCreationForm):
    email = forms.EmailField(required=True)
    secret_word = forms.CharField(required=True, max_length=100, help_text="This field is required.")

    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'password1', 'password2', 'secret_word')

    def clean_secret_word(self):
        secret_word = self.cleaned_data.get('secret_word')
        if secret_word != "secret_word":
            raise forms.ValidationError('The secret word is incorrect.')
        return secret_word

    def save(self, commit=True):
        user = super(CustomUserCreationForm, self).save(commit=False)
        user.email = self.cleaned_data['email']
        user.secret_word = self.cleaned_data['secret_word']
        if commit:
            user.save()
        return user


class CustomAuthenticationForm(AuthenticationForm):
    pass  # Якщо потрібно, ви можете додати свої власні валідатори