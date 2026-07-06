public class PaymentRequestWrapper {
    public Customer customer;
    public Payment payment;
    
    public class Customer{
        public String name;
        public String email;
    }
    public class Payment{
        public Integer amount;
        public String currencyy;
    }
}
