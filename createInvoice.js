import { LightningElement, track } from 'lwc';
import fetchLineItems from '@salesforce/apex/CreateInvoiceController.fetchLineItems';

export default class CreateInvoice extends LightningElement {
   urlParams = [];
   columns = [
    {label: 'Parameter Name', fieldName: 'key', type: 'text'},
    {label: 'Value', fieldName: 'value', type: 'text'},
   ];

   @track lineItems = [];
   lineItemColumns = [
    {label: 'Description', fieldName: 'description', type:'text'},
    {label: 'Quantity', fieldName: 'quantity', type:'number'},
    {label: 'Unit Price', fieldName: 'unitPrice', type: 'currency'},
    {label: 'Amount', fieldName: 'amount', type: 'currency'},
   ];

   error;

   connectedCallback() {
       const queryParams = new URLSearchParams(window.location.search);

       const params = {};
       queryParams.forEach((value, key) => {
        const updatedKey = key.startsWith('c__') ? key.substring(3) : key;
        params[updatedKey] = value
        this.urlParams.push({key: updatedKey, value});
       });

       this.fetchLineItems(params);
       //console.log(this.lineItems)
   }

   fetchLineItems(params){
        const {
            origin_record,
            child_relationship_name, 
            line_item_description, 
            line_item_quantity, 
            line_item_unit_price 
        } = params;

        if(!origin_record || !child_relationship_name){
            console.log(origin_record);
            this.error = 'Parameters missing : '+origin_record +' :: '+child_relationship_name;
            console.log(child_relationship_name);
            return;
        }

        const query = `SELECT ${line_item_description}, 
                        ${line_item_quantity}, ${line_item_unit_price} FROM ${child_relationship_name} WHERE ${child_relationship_name.substring(0, child_relationship_name.length - 8)}Id = \'${origin_record}\'`;

        fetchLineItems({query})
            .then((results) => {
                //console.log('Result : ',results);
                if(results.length > 0){
                    this.lineItems = results.map((item) => ({
                            description: item[line_item_description],
                            quantity: item[line_item_quantity],
                            unitPrice: item[line_item_unit_price],
                            amount: item[line_item_quantity] * item[line_item_unit_price],
                    }));
                }
                else{
                    this.error = 'No line items found.';
                }
            })
            .catch((error) => {
                this.error = `Error fetching items : ${error.body ? error.body.message : error}`;
            })
        //console.log(JSON.Parse(JSON.stringify(this.lineItems)));
   }
}