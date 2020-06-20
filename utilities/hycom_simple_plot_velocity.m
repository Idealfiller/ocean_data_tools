%  Author: Laur Ferris
%  Email address: lnferris@alum.mit.edu
%  Website: https://github.com/lnferris/ocean_data_tools
%  Jun 2020; Last revision: 20-Jun-2020
%  Distributed under the terms of the MIT License
%  Dependencies: nctoolbox

function hycom_simple_plot_velocity(url,date,region,depth,arrows)

    nc = ncgeodataset(url); % Assign a ncgeodataset handle.
    nc.variables            % Print list of available variables. 
    sv = nc{'water_u'};     % Assign ncgeovariable handle.
    sv_v = nc{'water_v'}; 
    sv.attributes % Print ncgeovariable attributes.
    datestr(sv.timeextent(),29) % Print date range of the ncgeovariable.
    svg = sv.grid_interop(:,:,:,:); % Get standardized (time,z,lat,lon) coordinates for the ncgeovariable.

    % Find Indices
    [tin,~] = near(svg.time,datenum(date,'dd-mmm-yyyy HH:MM:SS'));  % Find time index near date of interest. 
    [din,~] = near(svg.z,depth); % Choose index of depth (z-level) to use for 2-D plots; see svg.z for options.

    [lats,~] = near(svg.lat,region(1)); % Find lat index near southern boundary [-90 90] of region.
    [latn,~] = near(svg.lat,region(2));

    if region(3) > 180
        region(3) = region(3)-360;
    end
    if region(4) > 180
        region(4) = region(4)-360;
    end

    if region(3) > region(4) && region(4) < 0 % If data spans the dateline...

        [lonw_A] = near(svg.lon,region(3));% Find lon indexes of lefthand chunk.
        [lone_A] = near(svg.lon,180);
        [lonw_B] = near(svg.lon,-180);% Find lon indexes of righthand chunk.
        [lone_B] = near(svg.lon,region(4));

    else

        [lonw] = near(svg.lon,region(3));% Find lon indexes in standard manner.
        [lone] = near(svg.lon,region(4));

    end

    % Plot one depth level (2-D) of velocity magnitude sqrt(u^2+v^2)

    if region(3) > region(4) && region(4) < 0 % If data spans the dateline...  

        % Right    
        velocity = sqrt(double(sv.data(tin,din,lats:latn,lonw_A:lone_A)).^2+double(sv_v.data(tin,din,lats:latn,lonw_A:lone_A)).^2);
        figA = figure; % Plot one depth level.
        pcolorjw(svg.lon(lonw_A:lone_A),svg.lat(lats:latn),velocity); % pcolorjw(x,y,c);    

        % Left 
        velocity = sqrt(double(sv.data(tin,din,lats:latn,lonw_B:lone_B)).^2+double(sv_v.data(tin,din,lats:latn,lonw_B:lone_B)).^2);
        figB = figure; % Plot one depth level.
        pcolorjw(svg.lon(lonw_B:lone_B)+360,svg.lat(lats:latn),velocity); % pcolorjw(x,y,c); 

        % Merge left and right
        merge_figures(figA,figB)
        title({sprintf('velocity magnitude %.0fm',svg.z(din));datestr(svg.time(tin))},'interpreter','none');
        hcb = colorbar; title(hcb,sv.attribute('units'));

        if nargin == 6 && arrows==1

            u_left = squeeze(double(sv.data(tin,din,lats:latn,lonw_B:lone_B))); % Add directional arrows.
            v_left = squeeze(double(sv_v.data(tin,din,lats:latn,lonw_B:lone_B)));
            lon_left = svg.lon(lonw_B:lone_B)+360;
            u_right = squeeze(double(sv.data(tin,din,lats:latn,lonw_A:lone_A)));  % Add directional arrows.
            v_right  = squeeze(double(sv_v.data(tin,din,lats:latn,lonw_A:lone_A)));
            lon_right = svg.lon(lonw_A:lone_A);
            hold on
            quiver([lon_left; lon_right],svg.lat(lats:latn),cat(2,u_left,u_right),cat(2,v_left,v_right),'w'); % quiver(x,y,u,v)

        end

    else

        % Or just plot.    
        velocity = sqrt(double(sv.data(tin,din,lats:latn,lonw:lone)).^2+double(sv_v.data(tin,din,lats:latn,lonw:lone)).^2);

        figure % Plot one depth level.
        pcolorjw(svg.lon(lonw:lone),svg.lat(lats:latn),velocity); % pcolorjw(x,y,c)
        title({sprintf('velocity magnitude %.0fm',svg.z(din));datestr(svg.time(tin))},'interpreter','none');
        hcb = colorbar; title(hcb,sv.attribute('units'));

        if nargin == 6 && arrows==1
            u = squeeze(double(sv.data(tin,din,lats:latn,lonw:lone))); % Add directional arrows.
            v = squeeze(double(sv_v.data(tin,din,lats:latn,lonw:lone)));
            hold on
            quiver(svg.lon(lonw:lone),svg.lat(lats:latn),u,v,'w'); % quiver(x,y,u,v)
        end

    end

end