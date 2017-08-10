function [xml_struct_out] = strip_JAAD_xml(xml_struct_in)
%This file parses an xml struct from the JAAD dataset, removing uneccessary
%stuff. struct in can be constructed using xml2struct
%   @param xml_struct_in {struct} -- intial struct representing xml data
%   @return xml_struct {struct} -- a condensed struct with sufficient data

    % parse xml file
    
    % if xml_struct_in is empty, return
    
    if(~isempty(xml_struct_in.Children))
        
        % resize xml_struct_in
        sz = size(xml_struct_in.Children,2);
        xml_struct_in.Children = xml_struct_in.Children([2:2:sz]);
        
        % for each element in the struct do the same thing
        sz = size(xml_struct_in.Children,2);
        for i = 1:sz
            tmp = strip_JAAD_xml(xml_struct_in.Children(i));
            xml_struct_in.Children(i) = tmp;
                    
        end
        
    end
    
    xml_struct_out = xml_struct_in;
    
end

