import { LightningElement,api } from 'lwc';

export default class BaseElement extends LightningElement {

 @api  get  myName()
 {
     return "my name is lalit" ;
 }

}