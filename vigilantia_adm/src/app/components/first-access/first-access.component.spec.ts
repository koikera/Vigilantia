import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FirstAccessComponent } from './first-access.component';

describe('FirstAccessComponent', () => {
  let component: FirstAccessComponent;
  let fixture: ComponentFixture<FirstAccessComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FirstAccessComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(FirstAccessComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
