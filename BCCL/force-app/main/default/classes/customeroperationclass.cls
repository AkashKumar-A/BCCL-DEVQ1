public class customeroperationclass {
   
   Double regulardiscount = 0.1  ;
    
    public customeroperationclass()
    {
        System.debug('initiated');
    }
    
    public   Double finalvalue(integer price)
    {
        
       Double finalprice =   price - ( price * regulardiscount );
        
        return finalprice ;
    }
      
 
    
  
    
}