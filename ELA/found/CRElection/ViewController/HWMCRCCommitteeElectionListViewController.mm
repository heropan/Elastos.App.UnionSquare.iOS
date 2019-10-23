//
//  HWMCRCCommitteeElectionListViewController.m
//  elastos wallet
//
//  Created by 韩铭文 on 2019/9/5.
//

#import "HWMCRCCommitteeElectionListViewController.h"
#import "HWMVoteTheEditorialBoardTableViewCell.h"
#import "FLNotePointDBManager.h"
#import "HMWinputVotesPopupWindowView.h"
#import "ELWalletManager.h"
#import "HMWpwdPopupView.h"
#import "HMWSendSuccessPopuView.h"
#import "HMWToDeleteTheWalletPopView.h"
#import "HMWFMDBManager.h"
#import "HWMCRListModel.h"
#import "HWMTransactionDetailsView.h"
#import "HWMSignatureTradingSingleQrCodeViewController.h"

static NSString *cellString=@"HWMVoteTheEditorialBoardTableViewCell";
@interface HWMCRCCommitteeElectionListViewController ()<UITableViewDelegate,UITableViewDataSource,HMWpwdPopupViewDelegate,VotesPopupViewDelegate,HMWToDeleteTheWalletPopViewDelegate,HWMVoteTheEditorialBoardTableViewCellDeleate,UITextFieldDelegate,HWMTransactionDetailsViewDelegate>
@property(strong,nonatomic)HMWSendSuccessPopuView *sendSuccessPopuV;//交易成功 提示;
@property (weak, nonatomic) IBOutlet UILabel *TagtatolVoteLab;

@property (weak, nonatomic) IBOutlet UITableView *baseTableView;
@property(nonatomic,strong)UIImageView *placeHolferImage;

@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)UIButton *editBtn;//右 btn

//下三uibutton
@property (weak, nonatomic) IBOutlet UIButton *immediatelyToVoteButton;

@property(nonatomic,strong)NSMutableArray *voteArray;
@property(nonatomic,strong)NSMutableArray *deleteArray;

@property(nonatomic,strong)HMWinputVotesPopupWindowView *inputVoteTicketView;//票数视图
@property(strong,nonatomic)HMWpwdPopupView *pwdPopupV;//密码视图
@property(nonatomic,assign)NSInteger ticket;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *persentLab;
/*
 *<# #>
 */
@property(strong,nonatomic)HMWToDeleteTheWalletPopView *moreThan36View;
@property (weak, nonatomic) IBOutlet UILabel *TheAverageDistributionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *allTollTicketLabel;
@property (weak, nonatomic) IBOutlet UIButton *TheAverageDistributionButton;

@property (weak, nonatomic) IBOutlet UIImageView *TheAverageDistributionImageView;
/*
 *<# #>
 */
@property(assign,nonatomic)BOOL isMax;
/*
 *<# #>
 */
@property(strong,nonatomic)FLWallet *wallet;
/*
 *<# #>
 */
@property(strong,nonatomic)NSString *blaceString;
/*
 *<# #>
 */
@property(assign,nonatomic)double TheRemainingAvailable;
/*
 *<# #>
 */
@property(assign,nonatomic)BOOL WhetherTheAverage;
/*
 *<# #>
 */
@property(strong,nonatomic)HWMTransactionDetailsView *transactionDetailsView;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textLabelTopConSet;

@end

@implementation HWMCRCCommitteeElectionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@""];
    self.title=NSLocalizedString(@"CRC委员选举", nil);
    [self.immediatelyToVoteButton setTitle:NSLocalizedString(@"立即投票", nil) forState:UIControlStateNormal];
    [[HMWCommView share]makeBordersWithView:self.immediatelyToVoteButton];
    self.TheAverageDistributionTextLabel.text=NSLocalizedString(@"平均分配", nil);
    [self getWalletType];
    [self getDBRecored];
    [self makeView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.editBtn];
    CGFloat proFlo=[[self.persent substringToIndex:self.persent.length-1]floatValue]/100;
    self.progress.progress = proFlo;

    
 
}
-(void)getDBRecored{
    self.dataSource  = [[NSMutableArray alloc]initWithArray: [[HMWFMDBManager sharedManagerType:CRListType] allSelectCRWithWallID:self.wallet.masterWalletID ]];
    [self.baseTableView reloadData];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TableendEditing)];
    [self.baseTableView addGestureRecognizer:tap];
}
-(void)TableendEditing{
    [self.view endEditing:YES];
}
-(void)getWalletType{
    
    NSArray *walletArray=[NSArray arrayWithArray:[[HMWFMDBManager sharedManagerType:walletType] allRecordWallet]];
    FMDBWalletModel *model =walletArray[[[STANDARD_USER_DEFAULT valueForKey:selectIndexWallet] integerValue]];
    
self.wallet =[[FLWallet alloc]init];
 self.wallet.masterWalletID =model.walletID;
self.wallet.walletName     =model.walletName;
self.wallet.walletAddress  = model.walletAddress;
self.wallet.walletID       =[NSString stringWithFormat:@"%@%@",@"wallet",[[FLTools share] getNowTimeTimestamp]];
self.wallet.TypeW  = model.TypeW;
    
    invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.wallet.masterWalletID] callbackId: self.wallet.masterWalletID className:@"Wallet" methodName:@"getAllSubWallets"];
    
    PluginResult * resultBase =[[ELWalletManager share]getMasterWalletBasicInfo:mommand];
    NSString *statusBase=[NSString stringWithFormat:@"%@",resultBase.status];
    NSDictionary *baseDic=[[NSDictionary alloc]init];
    if ([statusBase isEqualToString:@"1"] ) {
        baseDic=[[FLTools share]dictionaryWithJsonString:resultBase.message[@"success"]];
        NSString *Readonly=[NSString stringWithFormat:@"%@",baseDic[@"Readonly"]];
        if ([Readonly isEqualToString:@"0"]) {
            if ([baseDic[@"M"] integerValue]==1) {
             self.wallet.TypeW=0;
            }else{
              
           self.wallet.TypeW=2;
            }
        }else{
          
            if ([baseDic[@"M"] integerValue]==1) {
           self.wallet.TypeW=1;
            }else{
         self.wallet.TypeW=3;
            }
        }
        
        
    }
    ELWalletManager *manager   =  [ELWalletManager share];
          
          IMainchainSubWallet *mainchainSubWallet = [manager getWalletELASubWallet:manager.currentWallet.masterWalletID];
        String balanceSt = mainchainSubWallet->GetBalance();
       NSString * balanceString= [NSString stringWithCString:balanceSt.c_str() encoding:NSUTF8StringEncoding];
             NSInteger balance=[balanceString integerValue];
             self.inputVoteTicketView.votes =balance/unitNumber;
 self.blaceString=@(balance/unitNumber).stringValue;
    
        self.TagtatolVoteLab.text = [NSLocalizedString(@"最大表决票权约：",nil ) stringByAppendingString: self.blaceString];
    
    [self  UpdateTheRemainingAvailable];
}

-(HMWToDeleteTheWalletPopView *)moreThan36View{
    if (!_moreThan36View) {
        _moreThan36View =[[HMWToDeleteTheWalletPopView alloc]init];
        _moreThan36View.delegate=self;
        _moreThan36View.deleteType=moreThan36SelectList;
    }
    return _moreThan36View;
}
-(void)selectMoreThan36{
    UIView *maView=[self mainWindow];
    [maView addSubview:self.moreThan36View];
    [self.moreThan36View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(maView);
    }];
    
    
}
#pragma mark ---------HMWToDeleteTheWalletPopViewDelegate----------
-(void)sureToDeleteViewWithPWD:(NSString*)pwd{
    [self clearVoteArray];
    for (int i= 0; i<36; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        [self.baseTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.baseTableView didSelectRowAtIndexPath:index];
    }
//    self.selectAllBtn.selected=YES;
    [self toCancelOrCloseDelegate];
}
-(void)toCancelOrCloseDelegate{
    [self.moreThan36View removeFromSuperview];
    self.moreThan36View=nil;
}
- (IBAction)actAction:(UIButton*)sender {
    
    if (self.editBtn.isSelected) {
        
        for (int i= 0; i<self.voteArray.count; i++) {
            FLCoinPointInfoModel *model = self.voteArray[i];
            NSArray *walletArray=[NSArray arrayWithArray:[[HMWFMDBManager sharedManagerType:walletType] allRecordWallet]];
            FMDBWalletModel *FMDBmodel =walletArray[[[STANDARD_USER_DEFAULT valueForKey:selectIndexWallet] integerValue]];
            [[FLNotePointDBManager defultWithWalletID:FMDBmodel.walletID]delectRecord:model];
            [self.dataSource removeObject:model];
        }
        [self.voteArray removeAllObjects];
        
        [self.baseTableView reloadData];
        [self updataBottomBtn];
        
    }else{
        if (self.voteArray.count == 0) {
            return;
        }
        if (self.voteArray.count>36) {
            [[FLTools share]showErrorInfo:NSLocalizedString(@"最多可选36个节点", nil)];
            return;
        }
        
        ELWalletManager *manager   =  [ELWalletManager share];
        
        IMainchainSubWallet *mainchainSubWallet = [manager getWalletELASubWallet:manager.currentWallet.masterWalletID];
        [self.view.window addSubview:self.inputVoteTicketView];
        //        Elastos::ElaWallet::BalanceType type = Elastos::ElaWallet::Total;
        String balanceSt = mainchainSubWallet->GetBalance();
        NSString * balanceString= [NSString stringWithCString:balanceSt.c_str() encoding:NSUTF8StringEncoding];
        NSInteger balance=[balanceString integerValue];
        self.inputVoteTicketView.votes =balance/unitNumber;
        
//        self.inputVoteTicketView.accountBalanceLab.text = [NSLocalizedString(@"最大表决票权 ",nil ) stringByAppendingString: @(balance/unitNumber).stringValue];
        [self  UpdateTheRemainingAvailable];
        
    }
    
}


- (IBAction)selectAllAction:(UIButton*)sender {
    
    
   
    if (sender.isSelected) {
        [self clearVoteArray];
        sender.selected = NO;
        for (int i= 0; i<self.dataSource.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            [self.baseTableView deselectRowAtIndexPath:index animated:YES];
            [self tableView:self.baseTableView didDeselectRowAtIndexPath:index];
        }
    }else{
        
        if (self.dataSource.count>36) {
            [self  selectMoreThan36];
            return;
        }
        [self clearVoteArray];
        sender.selected = YES;
        
        for (int i= 0; i<self.dataSource.count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            [self.baseTableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.baseTableView didSelectRowAtIndexPath:index];
        }
    }
    
}
-(void)clearVoteArray{
    
    [self.voteArray removeAllObjects];
    [self.baseTableView reloadData];
    [self updataBottomBtn];
}
-(void)makeView{
    self.baseTableView.delegate=self;
    self.baseTableView.dataSource=self;
    self.baseTableView.rowHeight=130;
    self.baseTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.baseTableView registerNib:[UINib nibWithNibName:cellString bundle:nil] forCellReuseIdentifier:cellString];
    self.baseTableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.baseTableView.allowsMultipleSelection = YES;
    
    [self.view addSubview:self.placeHolferImage];
//    CGPoint certer=self.baseTableView.center;
//    certer.x=certer.x;
    self.placeHolferImage.center =self.view.center;
    self.placeHolferImage.hidden = self.dataSource.count!=0;
    if (self.editBtn.isEnabled==NO&&self.dataSource.count==0) {
        
    }
    self.baseTableView.backgroundColor=[UIColor clearColor];
    [self updataBottomBtn];
}

-(void)updataBottomBtn{
//    self.hasSelectNumber.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.voteArray.count,NSLocalizedString(@"已选择", nil)];
//    [self.selectAllBtn  setTitle:[NSString stringWithFormat:@"%@(%lu/%ld)",NSLocalizedString(@"全选", nil), self.voteArray.count,self.dataSource.count] forState:UIControlStateNormal]  ;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HWMVoteTheEditorialBoardTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellString];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    HWMCRListModel *model = self.dataSource[indexPath.row];
    cell.deleagte=self;
    cell.index=indexPath;
    cell.model = model;
    cell.numberVotingTextField.delegate=self;
    cell.numberVotingTextField.tag=100+indexPath.row;
    [cell.numberVotingTextField addTarget:self action:@selector(valuechanged:) forControlEvents:UIControlEventValueChanged];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}

-(void)editStateChange:(UIButton*)btn{
    self.editBtn.selected = !self.editBtn.isSelected;
    NSString *title = self.editBtn.isSelected ?NSLocalizedString(@"删除", nil):NSLocalizedString(@"立即投票", nil);
    [self.immediatelyToVoteButton setTitle:title forState:UIControlStateNormal];
    if (self.editBtn.selected) {
        self.allTollTicketLabel.alpha=0.f;
        [self.immediatelyToVoteButton setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
        self.textLabelTopConSet.constant=20.f;
        self.TheAverageDistributionTextLabel.text=NSLocalizedString(@"全选", nil);
    }else{
        self.TheRemainingAvailable=0.f;
         [self UpdateTheRemainingAvailable];
        self.allTollTicketLabel.alpha=1.f;
        [self.immediatelyToVoteButton setTitle:NSLocalizedString(@"立即投票", nil) forState:UIControlStateNormal];
        self.textLabelTopConSet.constant=10.f;
         self.TheAverageDistributionTextLabel.text=NSLocalizedString(@"平均分配", nil);
    }
    
        for (int i=0; i<self.dataSource.count; i++) {
           NSIndexPath * index=[NSIndexPath indexPathForRow:i inSection:0];
          HWMCRListModel *model = self.dataSource[i];
           model.isCellSelected=NO;
            model.SinceVotes=@"0";
            self.dataSource[i]=model;
            HWMVoteTheEditorialBoardTableViewCell *cell=[self.baseTableView cellForRowAtIndexPath:index];
                   cell.model=model;
               cell.numberVotingTextField.text=nil;
        }
  
         self.TheAverageDistributionImageView.image=[UIImage imageNamed:@"found_vote_border"];
    [self clearVoteArray];
    
    
    
}

#pragma mark 代理
-(void)didHadInputVoteTicket:(NSString *)ticketNumer WithIsMax:(BOOL)isMax
{
    self.isMax=isMax;
    [self.inputVoteTicketView removeFromSuperview];
    self.inputVoteTicketView= nil;
    self.ticket = ticketNumer.integerValue;
    [self.view.window addSubview:self.pwdPopupV];
    
}
-(void)cancelThePWDPageView
{
    [self.pwdPopupV removeFromSuperview];
    self.pwdPopupV  = nil;
}
-(void)makeSureWithPWD:(NSString*)pwd{
    
    NSMutableArray *stringArray = [NSMutableArray array];
    for (int i= 0; i<self.voteArray.count; i++) {
        FLCoinPointInfoModel *model = self.voteArray[i];
        [stringArray addObject:model.ownerpublickey];
    }
    NSString *walletId = [ELWalletManager share].currentWallet.masterWalletID;
    NSInteger tic=self.ticket;
    if (self.isMax) {
        tic=-1;
    }
    BOOL ret = [[ELWalletManager share]useMainchainSubWallet:walletId ToVote:stringArray tickets:tic pwd:pwd isChangeVote:YES];
    if (ret) {
        [self showSendSuccessPopuV];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.sendSuccessPopuV removeFromSuperview];
            self.sendSuccessPopuV=nil;
        });
    }
    [self.pwdPopupV removeFromSuperview];
    self.pwdPopupV =  nil;
    
    
}

-(HMWSendSuccessPopuView *)sendSuccessPopuV{
    if (!_sendSuccessPopuV) {
        _sendSuccessPopuV =[[HMWSendSuccessPopuView alloc]init];
        UIView *manView=[self mainWindow];
        [manView addSubview:self.sendSuccessPopuV];
        [self.sendSuccessPopuV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(manView);
        }];
    }
    return _sendSuccessPopuV;
}
-(void)showSendSuccessPopuV{
    self.sendSuccessPopuV.hidden = NO;
}

#pragma mark lazy


-(HMWinputVotesPopupWindowView *)inputVoteTicketView
{
    if (!_inputVoteTicketView ) {
        _inputVoteTicketView = [[HMWinputVotesPopupWindowView alloc]init];
        _inputVoteTicketView.frame = [UIScreen mainScreen].bounds;
        _inputVoteTicketView.delegate = self;
    }
    return _inputVoteTicketView;
}
-(UIButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [[UIButton alloc]init];
        [_editBtn setImage:[UIImage imageNamed: @"found_vote_edit"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"found_vote_finish"] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(editStateChange:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _editBtn;
}
-(NSMutableArray *)voteArray
{
    if (!_voteArray) {
        _voteArray  =[NSMutableArray array];
    }
    return _voteArray;
}
-(NSMutableArray *)deleteArray
{
    if (!_deleteArray) {
        _deleteArray  =[NSMutableArray array];
    }
    return _deleteArray;
}
-(HMWpwdPopupView *)pwdPopupV{
    if (!_pwdPopupV) {
        _pwdPopupV=[[HMWpwdPopupView alloc]init];
        _pwdPopupV.frame = [UIScreen mainScreen].bounds;
        _pwdPopupV.delegate=self;
    }
    return _pwdPopupV;
    
}
-(UIImageView *)placeHolferImage
{
    if (!_placeHolferImage) {
        _placeHolferImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed: @"found_vote_empty_list"]];
        UILabel *textLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 160, 160, 40)];
        textLable.textColor=RGB(149, 159, 171);
        textLable.textAlignment=NSTextAlignmentCenter;
        textLable.text=NSLocalizedString(@"暂无候选委员", nil);
        [_placeHolferImage addSubview:textLable];
    }
    return _placeHolferImage;
    
}
- (IBAction)TheAverageDistributionImageViewEvent:(id)sender {
    self.WhetherTheAverage=!self.WhetherTheAverage;
    if (self.editBtn.isSelected) {
        for (int i=0; i<self.dataSource.count; i++) {
           NSIndexPath * index=[NSIndexPath indexPathForRow:i inSection:0];
          HWMCRListModel *model = self.dataSource[i];
        if (self.WhetherTheAverage) {
            model.isCellSelected=YES;
           }else{
           model.isCellSelected=NO;
           }
            model.SinceVotes=@"0";
            self.dataSource[i]=model;
            HWMVoteTheEditorialBoardTableViewCell *cell=[self.baseTableView cellForRowAtIndexPath:index];
                   cell.model=model;
               cell.numberVotingTextField.text=nil;
        }
        if (self.WhetherTheAverage) {
         self.TheAverageDistributionImageView.image=[UIImage imageNamed:@"all_selected"];
         }else{
         self.TheAverageDistributionImageView.image=[UIImage imageNamed:@"found_vote_border"];
         }
         [self.voteArray addObjectsFromArray:self.dataSource];
        return;
    }
    
    NSIndexPath *index;
     NSInteger PnumberVoting=[self.blaceString intValue]/self.dataSource.count;
    if (self.WhetherTheAverage) {
    self.TheAverageDistributionImageView.image=[UIImage imageNamed:@"all_selected"];
    }else{
    self.TheAverageDistributionImageView.image=[UIImage imageNamed:@"found_vote_border"];
        PnumberVoting=0;
    }
    self.TheRemainingAvailable=PnumberVoting*self.dataSource.count;
    for (int i=0; i<self.dataSource.count; i++) {
        index=[NSIndexPath indexPathForRow:i inSection:0];
          HWMCRListModel *model = self.dataSource[i];
        if (self.WhetherTheAverage) {
            model.isCellSelected=YES;
           }else{
           model.isCellSelected=NO;
           }
        model.SinceVotes=[NSString stringWithFormat:@"%ld",(long)PnumberVoting];
        HWMVoteTheEditorialBoardTableViewCell *cell=[self.baseTableView cellForRowAtIndexPath:index];
        cell.model=model;
    cell.numberVotingTextField.text=[NSString stringWithFormat:@"%ld",(long)PnumberVoting];
          self.dataSource[i]=model;
        [self.voteArray addObject:model];
    }
    [self UpdateTheRemainingAvailable];
       
    
}
-(void)UpdateTheRemainingAvailable{
    
    self.allTollTicketLabel.text=[NSString stringWithFormat:@"%@ %.4f ELA",NSLocalizedString(@"合计：",nil ),self.TheRemainingAvailable];
    self.persentLab.text=[NSString stringWithFormat:@"%@ %.0f ELA",NSLocalizedString(@"可用：",nil ),[self.blaceString doubleValue]- self.TheRemainingAvailable];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}
#pragma mark ---------HWMVoteTheEditorialBoardTableViewCell----------

-(void)addVoteWithIndex:(NSIndexPath *)index withVotes:(NSString *)votes{
     HWMCRListModel*model = self.dataSource[index.row];
     if ([self.voteArray containsObject:model]) {
         [self.voteArray removeObject:model];
         model.SinceVotes=@"0";
         model.isCellSelected=NO;
     }else{
         model.SinceVotes=votes;
         model.isCellSelected=YES;
         [self.voteArray addObject:model];
     }
    self.dataSource[index.row]=model;
    if (model.isCellSelected){
 self.TheRemainingAvailable=self.TheRemainingAvailable+[votes doubleValue];
    }else{
self.TheRemainingAvailable=self.TheRemainingAvailable-[votes doubleValue];
    }
    [self UpdateTheRemainingAvailable];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger tag=[textField tag];
    NSIndexPath *index=[NSIndexPath indexPathForRow:tag-100 inSection:0];
    HWMCRListModel *model=self.dataSource[index.row];
    if (model.isCellSelected) {
       if ([self.voteArray containsObject:model]) {
           self.TheRemainingAvailable=self.TheRemainingAvailable-[model.SinceVotes doubleValue];
       }
         model.SinceVotes=textField.text;
  self.TheRemainingAvailable=self.TheRemainingAvailable+[model.SinceVotes doubleValue];
       self.dataSource[index.row]=model;
        [self UpdateTheRemainingAvailable];
        
    }
    
}
- (IBAction)ImmediatelyToVote:(id)sender {
    if (self.editBtn.isSelected){
        if (self.voteArray.count==0) {
            return;
        }
        BOOL ret;
        for (HWMCRListModel *model in self.voteArray) {
         ret=  [[HMWFMDBManager sharedManagerType:CRListType]delectSelectCR:model WithWalletID:self.wallet.masterWalletID];
            [self.dataSource removeObject:model];
        }
        if (ret) {
            [[FLTools share]showErrorInfo:@"删除成功"];
            if (self.dataSource.count==0) {
                [self updatePlaceHoldInfo];
            }
                 
        }else{
             [[FLTools share]showErrorInfo:@"删除失败"];
        }
         [self clearVoteArray];
        
        return;
    }
    
    if (self.voteArray.count == 0||self.TheRemainingAvailable==0) {
                return;
            }
            if (self.voteArray.count>36) {
                [[FLTools share]showErrorInfo:NSLocalizedString(@"最多可选36个节点", nil)];
                return;
            }

    
    
    invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.wallet.masterWalletID,@"ELA",@"",@"",[NSString stringWithFormat:@"%.4f",self.TheRemainingAvailable],@"",@"",@"1"] callbackId:self.wallet.walletID className:@"Wallet" methodName:@"accessFees"];
    PluginResult * result =[[ELWalletManager share]accessFees:mommand];
    NSString *status=[NSString stringWithFormat:@"%@",result.status];
    if (![status isEqualToString:@"1"]) {
        return;
    }
    NSString *fee=[[FLTools share]elaScaleConversionWith:[NSString stringWithFormat:@"%@",result.message[@"success"]]];
    
    
    
    UIView *mainView =[self mainWindow];
    [mainView addSubview:self.transactionDetailsView];
    [self.transactionDetailsView TransactionDetailsWithFee:fee withTransactionDetailsAumont:[NSString stringWithFormat:@"%.4f",self.TheRemainingAvailable]];
    [self.transactionDetailsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(mainView);
    }];
}
-(HWMTransactionDetailsView *)transactionDetailsView{
    
    if (!_transactionDetailsView) {
        _transactionDetailsView =[[HWMTransactionDetailsView alloc]init];
        _transactionDetailsView.delegate=self;
    }
    return _transactionDetailsView;
}
#pragma mark ---------HWMTransactionDetailsView----------
-(void)closeTransactionDetailsView{
    [self.transactionDetailsView removeFromSuperview];
    self.transactionDetailsView=nil;
}
-(void)pwdAndInfoWithPWD:(NSString*)pwd{
    
    [self closeTransactionDetailsView];
    
    
    NSMutableArray *stringArray = [NSMutableArray array];
    NSMutableDictionary *CRDic=[[NSMutableDictionary alloc]init];
    for (int i= 0; i<self.voteArray.count; i++) {
        HWMCRListModel *model=self.voteArray[i];
        
        NSDictionary *dic=@{model.did: [NSString stringWithFormat:@"%ld",[model.SinceVotes integerValue]*unitNumber]};
    [CRDic addEntriesFromDictionary:dic];
//    [CRDic setObject:model.did forKey:[NSString stringWithFormat:@"%ld",[model.SinceVotes integerValue]*unitNumber]];
//        [stringArray addObject:dic];
    }
    NSInteger tic=self.TheRemainingAvailable;
//    if (self.isMax) {
//        tic=-1;
//    }

    
    
    
    if (self.wallet.TypeW==0) {
        NSString *walletId = [ELWalletManager share].currentWallet.masterWalletID;
        BOOL ret = [[ELWalletManager share]useCRMainchainSubWallet:walletId ToVote:CRDic tickets:0 pwd:pwd isChangeVote:YES];
        if (ret) {
            
            [self showSendSuccessPopuV];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.sendSuccessPopuV removeFromSuperview];
                self.sendSuccessPopuV=nil;
            });
            
        }
        [self.pwdPopupV removeFromSuperview];
        self.pwdPopupV =  nil;
    }else if (self.wallet.TypeW==1){
        invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.wallet.masterWalletID,stringArray,@(tic),pwd,@(1)] callbackId:self.wallet.masterWalletID className:@"Wallet" methodName:@"MSignAndReadOnlyCreateTransaction"];
        PluginResult *result = [[ELWalletManager share]SignReadOnlyToVote:mommand];
        NSString *statue=[NSString stringWithFormat:@"%@",result.status];
        if ([statue isEqualToString:@"1"]){
            HWMSignatureTradingSingleQrCodeViewController *SignatureTradingSingleQrCodeVC=[[HWMSignatureTradingSingleQrCodeViewController alloc]init];
              SignatureTradingSingleQrCodeVC.currentWallet=self.wallet;
            SignatureTradingSingleQrCodeVC.type=SingleSignReadOnlyToBeSigned;
            NSDictionary *successDic=[[NSDictionary alloc]initWithDictionary:result.message[@"success"]]; SignatureTradingSingleQrCodeVC.QRCodeString =[[FLTools share]DicToString:successDic];
           SignatureTradingSingleQrCodeVC.QRCodeSignatureDic=result.message[@"success"];
            SignatureTradingSingleQrCodeVC.subW=@"ELA";
            [self.navigationController pushViewController:SignatureTradingSingleQrCodeVC animated:YES];
        }
    }else if (self.wallet.TypeW==2){
        invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.wallet.masterWalletID,stringArray,@(tic),pwd,@(1)] callbackId:self.wallet.walletID className:@"Wallet" methodName:@"MSignAndReadOnlyCreateTransaction"];
        PluginResult *result = [[ELWalletManager share]HowSignToVote:mommand];
        NSString *statue=[NSString stringWithFormat:@"%@",result.status];
        if ([statue isEqualToString:@"1"]) {
            [self.pwdPopupV removeFromSuperview];
            self.pwdPopupV =  nil;
            HWMSignatureTradingSingleQrCodeViewController *SignatureTradingSingleQrCodeVC=[[HWMSignatureTradingSingleQrCodeViewController alloc]init];
               SignatureTradingSingleQrCodeVC.currentWallet=self.wallet;
            SignatureTradingSingleQrCodeVC.type=HowSignToBeSigned;
            SignatureTradingSingleQrCodeVC.QRCodeString =[[FLTools share]DicToString:result.message[@"success"]];
           SignatureTradingSingleQrCodeVC.QRCodeSignatureDic=result.message[@"success"]; SignatureTradingSingleQrCodeVC.subW=@"ELA";
            [self.navigationController pushViewController:SignatureTradingSingleQrCodeVC animated:YES];
        }
    }else if (self.wallet.TypeW==3){
        invokedUrlCommand *mommand=[[invokedUrlCommand alloc]initWithArguments:@[self.wallet.masterWalletID,stringArray,@(tic),pwd,@(1)] callbackId:self.wallet.walletID className:@"Wallet" methodName:@"MSignAndReadOnlyCreateTransaction"];
        PluginResult *result = [[ELWalletManager share]SignReadOnlyToVote:mommand];
        NSString *statue=[NSString stringWithFormat:@"%@",result.status];
        if ([statue isEqualToString:@"1"]) {
            HWMSignatureTradingSingleQrCodeViewController *SignatureTradingSingleQrCodeVC=[[HWMSignatureTradingSingleQrCodeViewController alloc]init];
               SignatureTradingSingleQrCodeVC.currentWallet=self.wallet;
            SignatureTradingSingleQrCodeVC.type=HowSignToBeSigned;
            SignatureTradingSingleQrCodeVC.QRCodeString =[[FLTools share]DicToString:result.message[@"success"]];
            SignatureTradingSingleQrCodeVC.QRCodeSignatureDic=result.message[@"success"];
            SignatureTradingSingleQrCodeVC.subW=@"ELA";
            [self.navigationController pushViewController:SignatureTradingSingleQrCodeVC animated:YES];
        }
    }
}
-(void)updatePlaceHoldInfo{
     self.placeHolferImage.hidden = self.dataSource.count!=0;
    if (self.dataSource.count==0) {
        self.editBtn.alpha=0;
        self.TagtatolVoteLab.alpha=0.f;
        self.persentLab.alpha=0.f;
        if (self.editBtn.isSelected) {
            [self editStateChange:self.editBtn];
        }
    self.allTollTicketLabel.text=[NSString stringWithFormat:@"%@ %@ ELA",NSLocalizedString(@"合计：",nil ),@"--"];
        
      }
    
}
@end