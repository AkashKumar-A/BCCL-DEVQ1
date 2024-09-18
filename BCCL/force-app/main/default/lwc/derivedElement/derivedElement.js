import { LightningElement,api } from 'lwc';
import {BaseElement} from 'c/baseElement'

export default class DerivedElement extends  LightningElement{

   @api name = this.myName;
   
}