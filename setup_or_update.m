function setup_or_update()
  %% PREAMBLE
  % This file generates the Anymatrix collection that contains the SLICOT
  % benchmark problems. This collection ships with a script (this file) that
  % downloads the data from slicot.org and generates the corresponding
  % functions.Therefore, no third party files are downloaded as part of the
  % repository.
  %
  % Currently, I'm installing the group like this:
  %
  %    >> anymatrix('g', 'slicot', 'mfasi/slicot')
  %    >> run([fileparts(which('anymatrix')) '/slicot/private/setup'])
  %
  % This script must be executed directly by the user, and as such it is not
  % well integrated into the current stable release of Anymatrix. Below are
  % some thoughts on what would improve the situation for this collection. I am
  % not claiming that these changes would be useful (or even advisable) in
  % general.
  %
  % 1. The user has to run this script manually, which is not ideal. Would it
  %    be possible to make anymatrix.m run a default setup script, if present
  %    if the downloaded group has one? Clearly, asking the user for a
  %    confirmation before running the script would be necessary (MATLAB can
  %    run shell commands, after all).
  %
  % 2. Each of the test problems includes a number of matrices (up to 14). As
  %    none of the matrices is necessarily more important than the other, the
  %    collection currently ignores the properties. Would it be better to
  %    choose the first output as "the" matrix and only return its properties?

  %% Begin of actual script
  % Directory structure.
  root_dir = fileparts([mfilename('fullpath') '.m']); % Generator functions.
  mat_dir_name = 'mat_files';   % Files downloaded from slicot.org.

  % Download SLICOT benchmark examples in subfloder.
  slicot_dir_name = sprintf('%s/%s', root_dir, mat_dir_name);
  if ~exist(slicot_dir_name, 'dir')
    mkdir(slicot_dir_name);
    cd(slicot_dir_name);
    unzip('http://slicot.org/objects/software/shared/bench-data/All-Data.zip');
    cd(root_dir);
  end

  % Open main and write headers files.
  contents_file_name = sprintf('%s/%s', root_dir, 'Contents.m');
  contents_file = fopen(contents_file_name, 'w');
  fprintf(contents_file, ...
          ['%%   SLICOT (Anymatrix group SLICOT)\n%%\n',...
           '%%   A collection of Benchmark Examples for Model ',...
           'Reduction of Linear\n',...
           '%%   Time-Invariant Dynamical Systems.\n%%\n',...
           '%%   Details on the test problem can be found in:\n',...
           '%%     [1] Y. Chahlaoui & P. Van Dooren (2005) ',...
           'Benchmark Examples for Model\n',...
           '%%         Reduction of Linear Time-Invariant ',...
           'Dynamical Systems, Dimension\n',...
           '%%         Reduction of Large-Scale Systems. ',...
           'In: Benner, Sorensen, Mehrmann\n',...
           '%%         (eds) Dimension Reduction of ',...
           'Large-Scale Systems. Lecture Notes in\n',...
           '%%         Computational Science and Engineering. ',...
           'vol. 45, Springer, Berlin\n',...
           '%%         Heidelberg. DOI: 10.1007/3-540-27909-1_24\n%%\n']);


  properties_file_name = sprintf('%s/%s', root_dir, 'am_properties.m');
  properties_file = fopen(properties_file_name, 'w');
  fprintf(properties_file, 'function P = am_properties\n\nP = {');


  % Scan MAT files, generate functions, and fill Contents.m file.
  files = dir(slicot_dir_name);
  for i = 1:length(files)
    clearvars A B C D E R R1 R2 S S1 S2 hsv mag w
    curr_in_file = sprintf('%s/%s', slicot_dir_name, files(i).name);
    [file_path, file_name, file_ext] = fileparts(curr_in_file);
    if (strcmp(file_ext, '.mat'))
      function_name = strrep(lower(file_name), '-', '_');

      % Generate function file.
      curr_outfile_name = sprintf('%s/%s.m', root_dir, function_name);
      outfile = fopen(curr_outfile_name, 'w');
      file_vars = load(curr_in_file);
      output_vars = strjoin(sort(fieldnames(file_vars)), ', ');
      fprintf(outfile, 'function [%s] = %s()\n', output_vars, function_name);
      fprintf(outfile, ...
              ['%% Details on the test problem can be found in:\n',...
               '%%    [1] Y. Chahlaoui & P. Van Dooren (2005) Benchmark ',...
               'Examples for Model\n',...
               '%%        Reduction of Linear Time-Invariant Dynamical ',...
               'Systems, Dimension\n',...
               '%%        Reduction of Large-Scale Systems. In: Benner, ',...
               'Sorensen, Mehrmann\n',...
               '%%        (eds) Dimension Reduction of Large-Scale Systems. ',...
               'Lecture Notes in\n',...
               '%%        Computational Science and Engineering. vol. 45, ',...
               'Springer, Berlin,\n',...
               '%%        Heidelberg. DOI: 10.1007/3-540-27909-1_24\n\n']);
      fprintf(outfile, 'load(''%s/%s'')\n\n', slicot_dir_name, file_name);
      fprintf(outfile, 'end');
      fclose(outfile);

      % Add line to Contents.m files.
      fprintf(contents_file, '%%   %s\n', function_name);

      % Add line to am_properties.m files.
      fprintf(properties_file, '''%s'', {}\n', function_name);

    end
  end

  % Write footer of am_properties.m file.
  fprintf(properties_file, '};\nend');

  % Close main files.
  fclose(contents_file);
  fclose(properties_file);
end