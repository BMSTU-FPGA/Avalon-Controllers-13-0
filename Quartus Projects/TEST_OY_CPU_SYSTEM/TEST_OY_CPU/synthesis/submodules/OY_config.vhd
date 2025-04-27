configuration Automat_for_OY of OY is
	for Struct
		for Control_Unit : Control_automat
			use entity work.Control_automat(Mili_arch);
		end for;
	end for;
end configuration Automat_for_OY;