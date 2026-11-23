# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "accounts" {
  value = {
    for account_name, account in local.accounts : account_name => {
      id = aws_organizations_account.this[account_name].id
    }
  }
}
