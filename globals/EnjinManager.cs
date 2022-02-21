//for playfab_enjin_1
using Godot;
using System;
using Enjin.SDK;
using Enjin.SDK.Graphql;
using Enjin.SDK.Models;
using Enjin.SDK.ProjectSchema;
//using Enjin.SDK.PlayerSchema;
using Enjin.SDK.Shared;
using System.Collections.Generic;
using System.Reflection;

public class EnjinManager : Node
{
	public static ProjectClient project_client = new ProjectClient(EnjinHosts.KOVAN);
	public static PlayerClient player_client = new PlayerClient(EnjinHosts.KOVAN);
    public static AccessToken project_token;
	public static LinkingInfo linking_info;
	//public static GDScript resource_script = (GDScript) GD.Load("res://globals/GameInfo.gd");
	//public static Godot.Object GameInfo = (Godot.Object) resource_script.New();
	public static Player player;
	public static string player_name = "";
	public static Wallet player_wallet;
	public static string player_wallet_address = "";
	public static string Nanner = "3800000000003608";
//                                                                                                   look here	
//                                                                                                        V
    public static Godot.Collections.Dictionary<string, Godot.Collections.Dictionary<string, string>> asset_dict = new Godot.Collections.Dictionary<string, Godot.Collections.Dictionary<string, string>>();
    public static Godot.Collections.Dictionary<string, Godot.Collections.Dictionary<string, string>> balance_dict = new Godot.Collections.Dictionary<string, Godot.Collections.Dictionary<string, string>>();


	public override void _Ready()
	{
		GD.Print("Enjin madule loaded... ");	
		
		AuthProject req = new AuthProject().Uuid("df7ad0e7-4bce-43dc-9137-eae958234e53").Secret("G2DYXcKtWL4xjf4baZPYwWcEJWhK4gTzBTVwO09H");
		GraphqlResponse<AccessToken> res = project_client.AuthProject(req).Result;
		//GD.Print(res.IsSuccess);
		project_token = res.Result;
		project_client.Auth(project_token.Token);
		if (project_client.IsAuthenticated == true) {
			GD.Print("--Project Authenticated",project_client.IsAuthenticated);
			GetProjectAssets();        
		
	    }
    }

	public static void LoadPlayer(string _name) {
		AuthPlayer load_req = new AuthPlayer().Id(_name);
		GraphqlResponse<AccessToken> res = project_client.AuthPlayer(load_req).Result;
		AccessToken access_token = res.Result;

		player_client.Auth(access_token.Token);

		GD.Print("Enjin--Player Loaded:", player_client.IsAuthenticated);

		GetPlayer linking_req = new GetPlayer().Id(_name).WithLinkingInfo();
		GraphqlResponse<Player> linking_res = project_client.GetPlayer(linking_req).Result;
		player = linking_res.Result;
		linking_info = player.LinkingInfo;
		//GD.Print(player.LinkingInfo.Code);
		//GameInfo.Call("player_loaded", player.Id);
	}


    public static bool FindPlayer(string p) {  
		GD.Print("Enjin....Finding  Player");
		GetPlayer req = new GetPlayer().Id(p);
		GraphqlResponse<Player> res = project_client.GetPlayer(req).Result;
        if (res.Result != null) {
    		player = res.Result;
            //GD.Print("user found");
            return true;
        }
        //GD.Print("user not found");
        return false;
    }

	public static void CreatePlayer(string _name)	{
		GD.Print("Enjin....Creating  Player");

		CreatePlayer create_req = new CreatePlayer().Id(_name);
		GraphqlResponse<AccessToken> res = project_client.CreatePlayer(create_req).Result;
        if (res.IsSuccess){
		    AccessToken access_token = res.Result;
		    //GD.Print(res.Result);
            player_name = _name;
        }
	}

    public static string GetPlayerLinkingCode(string _name) {
		GD.Print("Enjin....Getting  Player Linking Code");
    	GetPlayer linking_req = new GetPlayer().Id(_name).WithLinkingInfo();
		GraphqlResponse<Player> res = project_client.GetPlayer(linking_req).Result;
        //GD.Print(res.Result);

        if (res.Result.LinkingInfo != null) {
            player = res.Result;
    		linking_info = player.LinkingInfo;
            GD.Print("! No wallet found.  Sending linking info !");
            return linking_info.Code;
        }
        GD.Print("! User has linked wallet !");
        return "wallet found";
    }

	public static string GetLinkingQr(string _name) {
		GD.Print("Enjin....Getting QR");

    	GetPlayer linking_req = new GetPlayer().Id(_name).WithLinkingInfo();
		GraphqlResponse<Player> res = project_client.GetPlayer(linking_req).Result;
        //GD.Print(res.Result);

        if (res.Result.LinkingInfo != null) {
            player = res.Result;
    		linking_info = player.LinkingInfo;
            GD.Print("!  Sending QR  !");
            return linking_info.Qr;
        }
        //GD.Print("user has linked wallet");
        return "wallet found";
    }

	public static void GetProjectAssets(){
		GD.Print("Enjin....Getting Project Assets");

        GetAssets assets = new GetAssets().Filter(new AssetFilter());
        GraphqlResponse<List<Asset>> res = project_client.GetAssets(assets).Result;

		GD.Print("Enjin----Project Assets Found:");
		for (int i = 0; i < res.Result.Count; i++){
		    Godot.Collections.Dictionary<string, string> asset = new Godot.Collections.Dictionary<string, string>();
			asset.Add("name", res.Result[i].Name);
			asset.Add("id", res.Result[i].Id);
			asset.Add("CreatedAt", res.Result[i].CreatedAt);
			asset_dict.Add(res.Result[i].Id, asset);

			GD.Print("-" , res.Result[i].Name);
		}
	}		

    public static void GetPlayerBalances(string wallet) {
		GD.Print("Enjin----Getting Player Balance:");

        GetBalances getBalances = new GetBalances().Filter(new BalanceFilter().Wallet(wallet)).WithBalWalletAddress();//.Filter(new BalanceFilter().Wallet(wallet));
        GraphqlResponse<List<Balance>> bal_res = project_client.GetBalances(getBalances).Result;

		GD.Print("Balance result:");
		for (int i = 0; i < bal_res.Result.Count; i++){
		    Godot.Collections.Dictionary<string, string> asset = new Godot.Collections.Dictionary<string, string>();
			asset.Add("id", bal_res.Result[i].Id);
			int val = (int)bal_res.Result[i].Value;
			asset.Add("value", val.ToString());
			balance_dict.Add(asset_dict[bal_res.Result[i].Id]["name"], asset);
			GD.Print("" , bal_res.Result[i].Wallet);
		}
		//ApproveSpending(player_wallet_address);

    }

    public static string GetPlayerWallet(string _name) {
		GD.Print("Enjin----Getting Player Wallet:");
        GetPlayer req = new GetPlayer().Id(_name).WithWallet();
		GraphqlResponse<Player> res = project_client.GetPlayer(req).Result;
		//GD.Print(res.Result);
		player = res.Result;
		player_wallet = player.Wallet;
		player_wallet_address = player_wallet.EthAddress;
        return player_wallet.EthAddress;
    }

	public static string GetAssetUri(string id){
		GD.Print("Enjin----Getting Asset URI:");
		GetAsset asset = new GetAsset().Id(id).WithMetadataUri().WithConfigData();
        GraphqlResponse<Asset> res = project_client.GetAsset(asset).Result;
		string uri = res.Result.ConfigData.MetadataUri;
		uri = uri.Replace("{id}", id);
		return uri; 
	}

	public static void Give_Nanner(string address) { 
		GD.Print("Enjin----Sending Nanner!");
		GD.Print("  -to: " + address);
//		MintInput input = new MintInput().To(address).Value("1");
//		MintAsset req = new MintAsset().EthAddress("0xBA78FB863cB75864A2D07A7D93426fd3791751bE").AssetId(Nanner).Mints(input);
//		GraphqlResponse<Request> res = project_client.MintAsset(req).Result;
//		GD.Print(res.Result);
	}

	public static void Send_Nanner_To_Project(string from){
		GD.Print("-----Selling a nanner");
//		SendAsset req = new SendAsset().EthAddress(from).RecipientAddress("0xBA78FB863cB75864A2D07A7D93426fd3791751bE").AssetId(Nanner).Value("1");  // Set this value for FT's	
//		GraphqlResponse<Request> res = project_client.SendAsset(req).Result;
//		if (res.IsSuccess != true) {
//			GD.Print(res);
//		}

	}

//	public static void ApproveSpending(string wallet) {
//		GD.Print("---Approving Spending:");

//		ApproveInput input = new ApproveInput().Value("1");
//		ApproveEnj req = new ApproveEnj().EthAddress(wallet).Value("2");
//		GraphqlResponse<Request> res = project_client.ApproveEnj(req).Result;
//		GD.Print(res.Result);
//	}

}