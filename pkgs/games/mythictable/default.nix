{
	stdenv,
	lib,
	dotnet-sdk_3,
	fetchFromGitLab,
	buildDotnetPackage,
	msbuild,
	dotnetPackages,
	linkFarmFromDrvs,
	fetchurl,
}: let
	rev = "d018005050a35112883b63d4573f3e43e5912d75";

	fetchNuGet = { name, version, sha256 }: fetchurl {
		name = "nuget-${name}-${version}.nupkg";
		url = "https://www.nuget.org/api/v2/package/${name}/${version}";
		inherit sha256;
	};

	nugetDeps = linkFarmFromDrvs "mythictable-nuget-deps" [
		(fetchNuGet {
			name = "Google.Cloud.Storage.V1";
			version = "3.1.0";
			sha256 = "1kq4qs5503vr6my3pb8ff3qcf5ril4l2jcd7w9mrfrk2cy6h57c3";
		}) (fetchNuGet {
			name = "Microsoft.AspNetCore.Authentication.JwtBearer";
			version = "3.0.0";
			sha256 = "16zi8i6q8y8asb01qvhc85i470l3kcljq7by7inq6i4bjphnbgvp";
		}) (fetchNuGet {
			name = "Microsoft.AspNetCore.Identity.EntityFrameworkCore";
			version = "3.0.0";
			sha256 = "1r1cav4rk3p0vqywxazmy58iivikl5jxdlwxj5kngfiwdiwxzi4i";
		}) (fetchNuGet {
			name = "Microsoft.EntityFrameworkCore.Design";
			version = "3.1.1";
			sha256 = "1r0l0piln7x1fabkng4982wnp7hhn7p7xn7qf6dwwv9fi9qr08z4";
		}) (fetchNuGet {
			name = "Microsoft.EntityFrameworkCore.InMemory";
			version = "3.1.1";
			sha256 = "18vpz6y796xn4pn50r78hk70jvh1zfjf6wvz8mqz09z6kh5pdyd3";
		}) (fetchNuGet {
			name = "Microsoft.EntityFrameworkCore.SqlServer";
			version = "3.1.1";
			sha256 = "1msiyx0y3wsgh23m5s33icg023169zdpn612y86r5kib4vg45y6h";
		}) (fetchNuGet {
			name = "Microsoft.VisualStudio.Web.CodeGeneration.Design";
			version = "3.1.1";
			sha256 = "0d7wrc1bh4sa4bfi3hxz2hqcanb4qa6qk567mic1v4ymwrvid9qf";
		}) (fetchNuGet {
			name = "Microsoft.AspNetCore.Mvc.NewtonsoftJson";
			version = "3.0.0";
			sha256 = "09l5a4whdpqrx3jmpq4ff141i2wx1pjxj1g8g0r18yghmd664n0b";
		}) (fetchNuGet {
			name = "Microsoft.AspNetCore.SignalR.Protocols.NewtonsoftJson";
			version = "3.0.0";
			sha256 = "0sb4l3q057ssnqhbwh8hs3va469ip21g50k85zfbm9s72nyd84b9";
		}) (fetchNuGet {
			name = "Mongo.Migration";
			version = "3.0.113";
			sha256 = "0vz1s535j4xsy5sfs65hwddfsj4md3gr14q8w2zq0wzbv62l897b";
		}) (fetchNuGet {
			name = "MongoDB.Driver";
			version = "2.10.2";
			sha256 = "0qa8sqg0lzz9galkkfyi8rkbkali0nxm3qd5y4dlxp96ngrq5ldz";
		}) (fetchNuGet {
			name = "NodaTime";
			version = "2.4.7";
			sha256 = "0yp18kv91lfqhrmryykznalq402d9569676nwz7zgirg8azkznzh";
		}) (fetchNuGet {
			name = "NodaTime.Serialization.JsonNet";
			version = "2.2.0";
			sha256 = "024dcmsrbsclbc0i67vrbray5qm6mdgzhnbyzvp8xl5zfg7s0bi6";
		}) (fetchNuGet {
			name = "DiceRoller";
			version = "4.0.0";
			sha256 = "0ybnhma64wpfl9wpcj9z4h1c6d3lbdcwy12n5ydqablg71d21a4h";
		}) (fetchNuGet {
			name = "Slugify.Core";
			version = "2.3.0";
			sha256 = "1ym83077q133fcwnn8fig6g1f60ip3cih5zn273xvlnsgi2p131y";
		}) (fetchNuGet {
			name = "Swashbuckle.AspNetCore.Swagger";
			version = "5.0.0";
			sha256 = "1341nv8nmh6avs3y7w2szzir5qd0bndxwrkdmvvj3hcxj1126w2f";
		}) (fetchNuGet {
			name = "Swashbuckle.AspNetCore.SwaggerGen";
			version = "5.0.0";
			sha256 = "00swg2avqnb38q2bsxljd34n8rpknp74h9vbn0fdnfds3a32cqr4";
		}) (fetchNuGet {
			name = "Microsoft.IdentityModel.Tokens";
			version = "5.6.0";
			sha256 = "12warwfv4wpp33i9mg8dmw60i57sfc736sa6sw200w9g4j5rgh0w";
		})
	];
in buildDotnetPackage rec {
	baseName = "mythictable";
	version = "0.0.0";

	src = fetchFromGitLab {
		owner = "mythicteam";
		repo = "mythictable";
		rev = rev;
		sha256 = "09agwwr4yf73wbxfbgigd792909jbjg4prgp97xvd1i0xzpvgnk3";
	};

	xBuildFiles = ["MythicTable.Server.sln"];

	nativeBuildInputs = [ dotnet-sdk_3 dotnetPackages.Nuget ];

	buildInputs = with dotnetPackages; [
	];

	# buildInputs = [
	# 	 spidermonkey_38 boost icu libxml2 libpng libjpeg
	# 	 zlib curl libogg libvorbis enet miniupnpc openal
	# 	 libGLU libGL xorgproto libX11 libXcursor nspr SDL2 gloox
	# 	 nvidia-texture-tools libsodium
	# ] ++ lib.optional withEditor wxGTK;

	configurePhase = ''
		export HOME=$(mktemp -d)
		export DOTNET_CLI_TELEMETRY_OPTOUT=1
		export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

		set -x

		runHook preConfigure

		nuget sources Add -Name nixos -Source "$PWD/nixos"
		nuget init "${nugetDeps}" "$PWD/nixos"

		# FIXME: https://github.com/NuGet/Home/issues/4413
		mkdir -p $HOME/.nuget/NuGet
		cp $HOME/.config/NuGet/NuGet.Config $HOME/.nuget/NuGet

		dotnet restore --source nixos

		runHook postConfigure
	'';

	buildPhase = ''
		runHook preBuild

		dotnet publish -c Release -o $out

		runHook postBuild
	'';

	installPhase = ''
		runHook preInstall

		runHook postInstall
	'';

	meta = with stdenv.lib; {
		description = "An Open Source Virtual Tabletop for playing games with friends all over the world.";
		homepage = https://www.mythictable.com/;
		licenses = [lib.licenses.asl20];
		maintainers = with maintainers; [kevincox];
	};
}
