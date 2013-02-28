Facter.add(:pagesize) do
  confine :kernel => "Linux"

  setcode do
    Facter::Util::Resolution.exec('getconf PAGESIZE')
  end
end
