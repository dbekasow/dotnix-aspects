# One desktop shell per host

Status: accepted; implemented. Narrows [ADR 0001](0001-split-aspects-into-role-catalogs.md) for integrated homes.

Selecting a desktop shell on a host selects that shell for every integrated home on that host. Repeating the selection per occupant creates conflicting sources of truth; a contradictory selection is an error, not an override. Personal settings and applications remain occupant choices. This decision does not select a greeter or govern standalone homes.
