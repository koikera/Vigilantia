import { Component } from '@angular/core';
import { FormControl, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { LoginModel } from '../../models/LoginModel';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';

@Component({
  selector: 'app-login',
  imports: [CommonModule,FormsModule, ReactiveFormsModule, RouterModule, HttpClientModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {

  public login: LoginModel = {} as LoginModel;

  actorForm: FormGroup = new FormGroup({
    email: new FormControl(this.login.email, [
      Validators.required,
      Validators.email,
    ]),
    senha: new FormControl(this.login.email, Validators.required),
  });
  get email() {
    return this.actorForm.get('email');
  }
  get senha() {
    return this.actorForm.get('senha');
  }

  onSubmit() {
    this.actorForm.markAllAsTouched();

    if (this.actorForm.invalid) {
      return;
    }

    
  }


}
