import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { LoginModel } from '../../models/LoginModel';
import { CommonModule } from '@angular/common';
import { LoginService } from '../../services/login.service';
import { ToastrModule, ToastrService } from 'ngx-toastr';
import { HttpClientModule } from '@angular/common/http';
@Component({
  selector: 'app-forgot-password',
  imports: [CommonModule,FormsModule, ReactiveFormsModule, HttpClientModule, ToastrModule],
  providers: [LoginService],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss'
})
export class ForgotPasswordComponent {

  public login: LoginModel = {} as LoginModel;
  private login_service = inject(LoginService);
  private toastr= inject(ToastrService);
  actorForm: FormGroup = new FormGroup({
    email: new FormControl(this.login.email, [
      Validators.required,
      Validators.email,
    ]),
  });
  get email() {
    return this.actorForm.get('email');
  }

  onSubmit() {
    this.actorForm.markAllAsTouched();

    if (this.actorForm.invalid) {
      return;
    }

    this.login_service.forgot_password(this.login.email).subscribe({
      next: (res) => {
        this.toastr.success(res.msg)
      },
      error: (err) => {
        this.toastr.success(err.error)

      },
      complete: () => {
      }
    })
    
  }

}
