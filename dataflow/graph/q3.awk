BEGIN{
  FS = OFS = "|"
  PROCINFO["sorted_in"] = "@ind_str_asc"
}
{
  Name[$1] = $3
  Canon[$1] = $4
  Ortho[$1] = $5
  Ortho_r[$5][++n_Ortho_r[$5]] = $1
  Accepted[$1]  = $6
  Syn[$1]  = $7
  Syn_r[$7][++n_Syn_r[$7]] = $1
  Inak[$1] = $8
}

END {

  # Model
  #  Name(canon=1) 🠔[ortho]≼ Name ≽[syn]🠖 Name ≽[ortho]🠖 Name(canon=1)
  
  # Example: find cases of inferred canon to canon
  # <set> IDs
  for (i in Name)
    # <filter> canon names
    if (Canon[i])
      # <subset> to those ortho-to names
      if (isarray(Ortho_r[i]))
        for (j in Ortho_r[i]) 
          # <subset> to those which have synonyms, and ortho to IDs
          # <filter> which are Canon
          if (Canon[Ortho[Syn[Ortho_r[i][j]]]])
            # <ouput>
            print i, j,
              Ortho_r[i][j],
              Syn[Ortho_r[i][j]],
              toupper(gensub(/-.*$/,"","G",Ortho_r[i][j])),
              Ortho[Syn[Ortho_r[i][j]]]
  
}
  
