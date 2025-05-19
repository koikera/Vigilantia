import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { FirstAccessComponent } from './components/first-access/first-access.component';

export const routes: Routes = [
    {
        path: 'login',
        component: LoginComponent
    },
    {
        path: 'first-access',
        component: FirstAccessComponent
    }
];
