-- Free SMS notices: carrier for email-to-SMS gateway routing.
-- Values: verizon|att|tmobile|sprint|uscellular|cricket|boost|metro
alter table customers
  add column if not exists sms_carrier text;
