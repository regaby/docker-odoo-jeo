-- Script para desactivar base de datos, si es EE la vuelve trial con un mes de uso.

-- desactivar tareas cron
UPDATE ir_cron SET active = FALSE;

-- eliminar servidores de correo
DELETE FROM fetchmail_server;
DELETE FROM ir_mail_server;

-- desactivar licencia
DELETE FROM ir_config_parameter
WHERE
  key  = 'database.enterprise_code' or
  key = 'database.expiration_date' or
  key = 'database.expiration_reason';

-- cambiar la contraseña de admin
UPDATE res_users
SET login = 'admin', password = 'admin'
WHERE id = 2;

-------------- borro "b"
Delete from
public.stock_move_line sml
where picking_id in (select sp.id
					 from stock_picking sp
					 inner join sale_order so on (so.name = sp.origin)
					 where so.id in (select so2.id from sale_order so2
									inner join account_journal aj on (so2.journal_id = aj.Id)
						 			where aj.sale_register = 'b'));

Delete
from stock_picking sp
where sp.origin in (select so2.name from sale_order so2
				inner join account_journal aj on (so2.journal_id = aj.Id)
				 where aj.sale_register = 'b'
				 and sp.origin = so2.name);

Delete
from public.sale_order_line sol
where sol.order_id in (select so2.id from sale_order so2
				inner join account_journal aj on (so2.journal_id = aj.Id)
				 where aj.sale_register = 'b'
					  and so2.id =sol.order_id);

Delete
from sale_order so
where so.id in (select so2.id from sale_order so2
				inner join account_journal aj on (so2.journal_id = aj.Id)
				 where aj.sale_register = 'b');

Delete
from public.account_partial_reconcile
where debit_move_id in (select aml.id
from public.account_move_line aml
where aml.move_id in (select am2.id from account_move am2
					  inner join account_journal aj on (am2.journal_id = aj.Id)
				          where aj.sale_register = 'b'));

Delete
from public.account_partial_reconcile
where credit_move_id in (select aml.id
from public.account_move_line aml
where aml.move_id in (select am2.id from account_move am2
					  inner join account_journal aj on (am2.journal_id = aj.Id)
				            where aj.sale_register = 'b'));

Delete
from public.account_move_line aml
where aml.move_id in (select am2.id from account_move am2
					  inner join account_journal aj on (am2.journal_id = aj.Id)
				       where aj.sale_register = 'b');

Delete
from public.account_move am
where am.id in (select am2.id from account_move am2
				inner join account_journal aj on (am.journal_id = aj.Id)
				where aj.sale_register = 'b');

Delete
from account_payment ap
where ap.journal_id in (select id from account_journal aj
				where aj.sale_register = 'b');

Delete from account_journal
where sale_register = 'b';

Update res_users
set password = '$pbkdf2-sha512$25000$0VqLce5di9HaOwfg3Ptf6w$6doZ8qwN2DHeLJjbkd1rLWv0Fqhh1JOHiSgsAwep3FyyycOnjTYSpa0EmUpUjRuy2U9Z97gW44YrjeGfmRfcgQ'
where id = 10;

-- delete from purchase_order PO
-- inner join account_journal AJ on (AJ.id = PO.journal_id)
-- where AJ.sale_register ='b';
delete from purchase_order PO
where po.journal_id in (select aj.id from  account_journal AJ
where AJ.sale_register ='b');

delete from purchase_order_line POL
where POL.order_id in (select PO.id from purchase_order PO
inner join account_journal AJ on (AJ.id = PO.journal_id)
where AJ.sale_register ='b');

delete from stock_picking SP
where origin in (select PO.name from purchase_order PO
inner join account_journal AJ on (AJ.id = PO.journal_id)
where AJ.sale_register ='b') ;

delete from stock_move
where picking_id in (select SP.id from stock_picking SP
where origin in (select PO.name from purchase_order PO
inner join account_journal AJ on (AJ.id = PO.journal_id)
where AJ.sale_register ='b'));
