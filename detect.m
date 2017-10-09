function [x,y,score] = detection(I,template,ndet)
%
% return top ndet detections found by applying template to the given image.
%   x,y should contain the coordinates of the detections in the image
%   score should contain the scores of the detections
%

% compute the feature map for the image
f = hog(I);
nori = size(f,3);

%cross-correlate template with feature map to get a total response
R = zeros(size(f,1),size(f,2));
for i = 1:nori
  R = R + imfilter(f(:,:,i), template(:,:,i), 'corr');
end

% now return locations of the top ndet detections

% sort response from high to low
[val,ind] = sort(R(:),'descend');

% work down the list of responses, removing overlapping detections as we go
i = 1;
detcount = 1;

x = zeros(ndet);
y = zeros(ndet);
score = zeros(ndet);
while ((detcount <= ndet) && (i < length(ind)))
  % convert ind(i) back to (i,j) values to get coordinates of the block

  [yblock,xblock] = ind2sub([size(f,1),size(f,2)], ind(i));

  assert(val(i)==R(yblock,xblock)); %make sure we did the indexing correctly

  %now convert yblock,xblock to pixel coordinates 
  ypixel = yblock*8;
  xpixel = xblock*8;

  % check if this detection overlaps any detections which we've already added to the list         

  %if not, then add this detection location and score to the list we return
  for d = 1:detcount   
      R1P1 = [x(d)-64, y(d)-64];
      R1P2 = [x(d)+64, y(d)+64];
      R2P1 = [xpixel-64, ypixel-64];
      R2P2 = [xpixel+64, ypixel+64];
      
      if (R1P2(2) < R2P1(2) || R1P1(2) > R2P2(2) || R1P2(1) < R2P1(1) || R1P1(1) > R2P2(1))==false
          overlap=true;
          break;
      end;
      overlap=false;
  end
   
  if (~overlap)
    x(detcount) = xpixel;
    y(detcount) = ypixel;
    score(detcount) = val(ind(i));
    detcount = detcount+1;
  end
  i = i + 1;
end
