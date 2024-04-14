function res = getCorner(id, data, t)
% Listing the spacings of and between all the AprilTags and extracting the
% rows and columns of the AprilTags from the given IDs

    tag_len = 0.152;
    tag_spacing = 0.152;
    special_tag_spacing = 0.178;
    AprilTag_corners = zeros(10,numel(length(data(t).id)));
    
    for i = 1: length(id)
        p = data(t).id(1,i);
        row = mod(p,12) + 1;
        
                
       if p >= 0 && p <= 11
            col = 1;
            x = 2*(row - 1)*tag_spacing;
            y = 2*(col - 1)*tag_spacing;

        elseif p >= 12 && p <= 23
            col = 2;
            x = 2*(row - 1)*tag_spacing;
            y = 2*(col - 1)*tag_spacing;

        elseif p >= 24 && p <= 35
            col = 3;
            x = 2*(row - 1)*tag_spacing;
            y = 2*(col - 1)*tag_spacing;

        elseif p >= 36 && p <= 47
            col = 4;
            x = 2*(row - 1)*tag_spacing;
            y = ((2*(col - 1))-1)*tag_spacing + special_tag_spacing;

        elseif p >= 48 && p <= 59
            col = 5;
            x = 2*(row - 1)*tag_spacing;
            y = ((2*(col - 1))-1)*tag_spacing + special_tag_spacing;

        elseif p >= 60 && p <= 71
            col = 6;
            x = 2*(row - 1)*tag_spacing;
            y = ((2*(col - 1))-1)*tag_spacing + special_tag_spacing;

        elseif p >= 72 && p <= 83
            col = 7;
            x = 2*(row - 1)*tag_spacing;
            y = ((2*(col - 1))-2)*tag_spacing + 2*special_tag_spacing;

        elseif p >= 84 && p <= 95
            col = 8;
            x = 2*(row - 1)*tag_spacing;
            y = ((2*(col - 1))-2)*tag_spacing + 2*special_tag_spacing;
        
       else
           col = 9;
            x = 2*(row - 1)*tag_spacing;
            y = ((2*(col - 1))-2)*tag_spacing + 2*special_tag_spacing;
       end
      


  %       p = 4
  %       row = mod(p,12) + 1
  %       col = ceil(p/11)
  % 
  % % Determining the corner for each AprilTag based on their location in
  % % terms of rows and columns
  % 
  %       if col == 1
  %           y = 0
  %       elseif col > 1 && col <= 3
  %           y = 2*(col - 1)*tag_spacing
  %       elseif col >= 4 && col <= 6
  %           y = ((2*(col - 1))-1)*tag_spacing + special_tag_spacing
  %       elseif col >= 7
  %           y = ((2*(col - 1))-2)*tag_spacing + 2*special_tag_spacing
  %       end
  % 
  %       if row == 1
  %           x = 0
  %       elseif row > 1
  %           x = 2*(row - 1)*tag_spacing
  %       end


 
           
 
    %% Output Parameter Description
    % res = List of the coordinates of the 4 corners (or 4 corners and the
    % centre) of each detected AprilTag in the image in a systematic method
     AprilTag_corners(:,i)= [x + (tag_len/2); y + (tag_len/2); x + tag_len; y; x + tag_len; y + tag_len; x; y + tag_len; x; y];
     res = AprilTag_corners;
    end
end