const db = require('./db');
const apiRpc = require('@eosio-toppings/api-rpc').default;

const get_contract_rows = async (query) => {
  try{
    let result = [];
    let { table, scope, code, endpoint } = query;

    let query_gen = `
        SELECT * FROM chain.contract_row
        WHERE chain.contract_row.table = '${table}'
        AND chain.contract_row.scope = '${scope}'
        AND chain.contract_row.code = '${code}'`;

    let promise = new Promise((resolve, reject)=>{
      db.query(query_gen, "", (err, result) => {
        if (err) {
          console.error('Error executing get action details query:: ', err.stack);
          resolve([]);
        }else{
          resolve(result.rows);
        }
      })
    })

    return await promise;

  }catch(err){
    console.log("caught exception ", err)
    return err;
  }
}

module.exports = get_contract_rows;
