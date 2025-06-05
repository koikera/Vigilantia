import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { LoginModel } from '../models/LoginModel';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment.development';

@Injectable({
  providedIn: 'root'
})
export class LoginService {

  constructor(private http: HttpClient) { }

  public login(login: LoginModel): Observable<any>{
    return this.http.post(`${environment.apiUrl}/login`, login)
  }
  public forgot_password(email: string): Observable<any>{
    return this.http.post(`${environment.apiUrl}/esqueceu-senha`, {email: email})
  }
}
