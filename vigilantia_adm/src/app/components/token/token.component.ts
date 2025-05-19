import { CommonModule } from '@angular/common';
import { Component, ElementRef, QueryList, ViewChildren } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-token',
  imports: [CommonModule, FormsModule],
  templateUrl: './token.component.html',
  styleUrl: './token.component.scss'
})
export class TokenComponent {
  inputs = new Array(6); 
  tokenArray: string[] = ['', '', '', '', '', ''];

  @ViewChildren('codeInput') codeInputs!: QueryList<ElementRef>;

  onInput(event: Event, index: number) {
    const input = event.target as HTMLInputElement;
    const value = input.value;

    // Apenas aceita número
    if (!/^\d$/.test(value)) {
      input.value = '';
      this.tokenArray[index] = '';
      return;
    }

    this.tokenArray[index] = value;

    // Vai para o próximo input
    if (value.length === 1 && index < this.tokenArray.length - 1) {
      const next = this.codeInputs.get(index + 1);
      next?.nativeElement.focus();
    }
  }

  send_token(){
    console.log(this.tokenArray)
  }

  get fullToken(): string {
    return this.tokenArray.join('');
  }


}
