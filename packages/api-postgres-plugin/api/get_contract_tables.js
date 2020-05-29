const db = require('./db');
const apiRpc = require('@eosio-toppings/api-rpc').default;

const get_contract_tables = async (query) => {
  try{
    let result = [];
    let { table, scope, endpoint } = query;

    let query_gen = `
        SELECT * FROM chain.contract_table
        WHERE chain.contract_table.table = '${table}'
        ${(scope !== undefined)
          ?
            `AND chain.contract_table.scope = '${scope}'`
          : ``
        }
        ORDER BY block_num DESC
        LIMIT 10`;

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
    let resultObj = await promise;
    let titles = [];

    if(resultObj.length > 0) {
      for (let item of resultObj) {
        // titles.push(item.scope)
        // title_string = title_string + `'${item.scope}',`

        let query_second = `
          SELECT * FROM chain.contract_row
          WHERE chain.contract_row.table = 'dgood'
          AND chain.contract_row.scope = '${item.scope}'
          ORDER BY block_num DESC
          LIMIT 100
        `;

        let second_promise = new Promise((resolve, reject)=>{
          db.query(query_second, "", (err, result) => {
            if (err) {
              console.error('Error executing get action details query:: ', err.stack);
              resolve([]);
            }else{
              resolve(result.rows);
            }
          })
        })
        let dgoodsObj = await second_promise;
        item['dgoods'] = dgoodsObj;
      }
      return resultObj
    }

    return resultObj


  }catch(err){
    console.log("caught exception ", err)
    return err;
  }
}

module.exports = get_contract_tables;
