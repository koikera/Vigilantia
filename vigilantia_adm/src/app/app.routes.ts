import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { FirstAccessComponent } from './components/first-access/first-access.component';
import { TokenComponent } from './components/token/token.component';
import { ForgotPasswordComponent } from './components/forgot-password/forgot-password.component';
import { HomeComponent } from './components/home/home.component';

export const routes: Routes = [
    {
        path: 'login',
        component: LoginComponent
    },
    {
        path: 'first-access',
        component: FirstAccessComponent
    },
    {
        path: 'token',
        component: TokenComponent
    },
    {
        path: 'forgot-password',
        component: ForgotPasswordComponent
    },
    {
        path: 'home',
        component: HomeComponent
    }
];
