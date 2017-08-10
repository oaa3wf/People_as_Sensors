function [ rows ] = find_m_st_m_i( map_data, position, value)
%FIND_M_ST_M_I: Find the maps M such that m_i = value
%   This function finds all maps M such that m_i = value
%   @param map_data is a mapping from the vectorized form of M to 
%   an index representing M. The rows number is the index and the value of
%   the row is the vectorized form of M.
%   @param position {int > 0} - i for m_i
%   @param value either 0 or 1 - value of m_i
%   @return rows - set of rows for which m_i = value

n_rows = size(map_data,1);
rows = [];

for i = 1:n_rows
    if(map_data(i,position) == value)
        rows=[rows;i];
    end
end

end

