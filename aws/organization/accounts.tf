# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_organizations_account" "this" {
  for_each = {
    for account_name, account in local.accounts : account_name => account
  }
  name              = each.key
  email             = each.value.email
  close_on_deletion = true
  parent_id         = aws_organizations_organizational_unit.this[each.value.organizational_unit].id
}
